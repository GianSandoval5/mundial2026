const { defineSecret, HttpsError, logger, onCall } = require("@flupibase/functions");

const API_FOOTBALL_BASE_URL = "https://v3.football.api-sports.io";
const WORLD_CUP_26_BASE_URL = "https://worldcup26.ir";
const WORLD_CUP_LEAGUE_ID = 1;
const WORLD_CUP_26_SEASON = 2026;
const CACHE_TTL_MS = 15 * 1000;

const apiFootballKey = defineSecret("API_FOOTBALL_KEY");
const worldCup26Cache = new Map();

exports.mundialitoFootball = onCall(
  {
    secrets: [apiFootballKey],
  },
  async (event) => {
    const data = event.data || {};
    const resource = String(data.resource || "fixtures");
    const season = readInt(data.season, WORLD_CUP_26_SEASON);
    const provider = chooseProvider(data.provider, season);

    validateCommonInput({ season, resource });

    logger.info("Mundialito football request", {
      provider,
      resource,
      season,
    });

    if (provider === "worldcup26") {
      return callWorldCup26(data, resource, season);
    }

    return callApiFootball(data, resource, season);
  },
);

async function callWorldCup26(data, resource, season) {
  if (season !== WORLD_CUP_26_SEASON) {
    throw new HttpsError(
      "invalid-argument",
      "WorldCup26 provider only supports the 2026 season.",
    );
  }

  switch (resource) {
    case "fixtures":
    case "live": {
      const [games, teams, stadiums] = await Promise.all([
        getWorldCup26Array("games", "/get/games"),
        getWorldCup26Array("teams", "/get/teams"),
        getWorldCup26Array("stadiums", "/get/stadiums"),
      ]);
      const teamMap = mapById(teams);
      const stadiumMap = mapById(stadiums);
      let fixtures = games.map((game) => normalizeWorldCup26Game(
        game,
        teamMap,
        stadiumMap,
      ));

      fixtures = filterWorldCup26Fixtures(fixtures, data);
      if (resource === "live") {
        fixtures = fixtures.filter((fixture) =>
          isLiveStatus(fixture.fixture.status.short),
        );
      }

      return envelope("worldcup26", resource, data, fixtures);
    }
    case "fixture": {
      const id = readInt(data.id, 0);
      if (id <= 0) {
        throw new HttpsError("invalid-argument", "Missing fixture id.");
      }

      const [games, teams, stadiums] = await Promise.all([
        getWorldCup26Array("games", "/get/games"),
        getWorldCup26Array("teams", "/get/teams"),
        getWorldCup26Array("stadiums", "/get/stadiums"),
      ]);
      const teamMap = mapById(teams);
      const stadiumMap = mapById(stadiums);
      const fixture = games
        .filter((game) => readInt(game.id, 0) === id || readInt(game._id, 0) === id)
        .map((game) => normalizeWorldCup26Game(game, teamMap, stadiumMap));

      return envelope("worldcup26", resource, data, fixture);
    }
    case "events": {
      const fixtureId = readInt(data.fixture || data.id, 0);
      if (fixtureId <= 0) {
        throw new HttpsError("invalid-argument", "Missing fixture id.");
      }

      const [games, teams, stadiums] = await Promise.all([
        getWorldCup26Array("games", "/get/games"),
        getWorldCup26Array("teams", "/get/teams"),
        getWorldCup26Array("stadiums", "/get/stadiums"),
      ]);
      const teamMap = mapById(teams);
      const stadiumMap = mapById(stadiums);
      const match = games
        .filter((game) =>
          readInt(game.id, 0) === fixtureId || readInt(game._id, 0) === fixtureId,
        )
        .map((game) => normalizeWorldCup26Game(game, teamMap, stadiumMap))[0];

      return envelope("worldcup26", resource, data, match ? match.events : []);
    }
    case "standings": {
      const [groups, teams] = await Promise.all([
        getWorldCup26Array("groups", "/get/groups"),
        getWorldCup26Array("teams", "/get/teams"),
      ]);
      const response = [
        {
          league: {
            id: WORLD_CUP_LEAGUE_ID,
            name: "World Cup",
            country: "World",
            season,
            standings: groups.map((group) => normalizeWorldCup26Group(group, teams)),
          },
        },
      ];

      return envelope("worldcup26", resource, data, response);
    }
    case "teams": {
      const teams = await getWorldCup26Array("teams", "/get/teams");
      const response = teams.map((team) => ({
        team: normalizeWorldCup26Team(team),
      }));

      return envelope("worldcup26", resource, data, response);
    }
    case "rounds": {
      const games = await getWorldCup26Array("games", "/get/games");
      const rounds = Array.from(
        new Set(games.map((game) => worldCup26Round(game)).filter(Boolean)),
      );

      return envelope("worldcup26", resource, data, rounds);
    }
    case "stadiums": {
      const stadiums = await getWorldCup26Array("stadiums", "/get/stadiums");
      return envelope("worldcup26", resource, data, stadiums);
    }
    default:
      throw new HttpsError(
        "invalid-argument",
        `Unsupported resource: ${resource}.`,
      );
  }
}

async function callApiFootball(data, resource, season) {
  const apiKey = apiFootballKey.value();
  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "Historical seasons require the API_FOOTBALL_KEY Flupibase secret.",
    );
  }

  const route = buildApiFootballRoute(data, resource, season);
  const upstreamUrl = new URL(`${API_FOOTBALL_BASE_URL}${route.path}`);
  for (const [key, value] of Object.entries(route.params)) {
    upstreamUrl.searchParams.set(key, String(value));
  }

  const response = await fetch(upstreamUrl, {
    headers: {
      accept: "application/json",
      "x-apisports-key": apiKey,
    },
  });

  const payload = await safeJson(response);
  if (!response.ok) {
    throw new HttpsError(
      "unavailable",
      `API-FOOTBALL returned HTTP ${response.status}.`,
      payload,
    );
  }

  return {
    provider: "api-football",
    ...payload,
  };
}

function buildApiFootballRoute(data, resource, season) {
  const league = readInt(data.league, WORLD_CUP_LEAGUE_ID);
  const timezone = cleanText(
    data.timezone || "America/Lima",
    /^[A-Za-z_/-]+$/,
    "America/Lima",
  );

  if (league <= 0) {
    throw new HttpsError("invalid-argument", "Invalid league.");
  }

  switch (resource) {
    case "fixtures":
      return {
        path: "/fixtures",
        params: cleanParams({
          league,
          season,
          timezone,
          round: cleanOptional(data.round, /^[A-Za-z0-9 ._-]+$/),
          date: cleanOptional(data.date, /^\d{4}-\d{2}-\d{2}$/),
          from: cleanOptional(data.from, /^\d{4}-\d{2}-\d{2}$/),
          to: cleanOptional(data.to, /^\d{4}-\d{2}-\d{2}$/),
        }),
      };
    case "live":
      return {
        path: "/fixtures",
        params: {
          league,
          season,
          status: "1H-HT-2H-ET-P-BT-LIVE",
          timezone,
        },
      };
    case "fixture": {
      const id = readInt(data.id, 0);
      if (id <= 0) {
        throw new HttpsError("invalid-argument", "Missing fixture id.");
      }
      return {
        path: "/fixtures",
        params: { id, timezone },
      };
    }
    case "events": {
      const fixture = readInt(data.fixture, 0);
      if (fixture <= 0) {
        throw new HttpsError("invalid-argument", "Missing fixture id.");
      }
      return {
        path: "/fixtures/events",
        params: { fixture },
      };
    }
    case "standings":
      return {
        path: "/standings",
        params: { league, season },
      };
    case "teams":
      return {
        path: "/teams",
        params: { league, season },
      };
    case "rounds":
      return {
        path: "/fixtures/rounds",
        params: { league, season },
      };
    default:
      throw new HttpsError(
        "invalid-argument",
        `Unsupported resource: ${resource}.`,
      );
  }
}

function chooseProvider(requestedProvider, season) {
  const requested = String(requestedProvider || "").trim().toLowerCase();
  if (requested === "worldcup26" || requested === "world-cup-26") {
    return "worldcup26";
  }
  if (requested === "api-football" || requested === "apifootball") {
    return "api-football";
  }

  return season === WORLD_CUP_26_SEASON ? "worldcup26" : "api-football";
}

function validateCommonInput({ season }) {
  if (season < 1930 || season > 2030) {
    throw new HttpsError("invalid-argument", "Invalid season.");
  }
}

async function getWorldCup26Array(key, path) {
  const now = Date.now();
  const cached = worldCup26Cache.get(key);
  if (cached && now - cached.updatedAt < CACHE_TTL_MS) {
    return cached.value;
  }

  const response = await fetch(`${WORLD_CUP_26_BASE_URL}${path}`, {
    headers: { accept: "application/json" },
  });
  const payload = await safeJson(response);
  if (!response.ok) {
    throw new HttpsError(
      "unavailable",
      `WorldCup26 returned HTTP ${response.status}.`,
      payload,
    );
  }

  const value = payload && Array.isArray(payload[key]) ? payload[key] : [];
  worldCup26Cache.set(key, { updatedAt: now, value });
  return value;
}

function normalizeWorldCup26Game(game, teamMap, stadiumMap) {
  const home = teamFromGame(game, "home", teamMap);
  const away = teamFromGame(game, "away", teamMap);
  const status = statusFromWorldCup26(game);
  const stadium = stadiumMap.get(readInt(game.stadium_id, 0));
  const fixtureId = readInt(game.id, readInt(game._id, 0));

  return {
    fixture: {
      id: fixtureId,
      timezone: "America/Lima",
      date: worldCup26DateToIso(game.local_date),
      venue: {
        id: readInt(game.stadium_id, 0),
        name: cleanString(stadium && (stadium.fifa_name || stadium.name_en)),
        city: stadiumCity(stadium),
      },
      status,
    },
    league: {
      id: WORLD_CUP_LEAGUE_ID,
      name: "World Cup",
      country: "World",
      season: WORLD_CUP_26_SEASON,
      round: worldCup26Round(game),
    },
    teams: {
      home,
      away,
    },
    goals: {
      home: status.short === "NS" ? null : nullableInt(game.home_score),
      away: status.short === "NS" ? null : nullableInt(game.away_score),
    },
    score: null,
    events: [
      ...scorerEvents(game.home_scorers, home),
      ...scorerEvents(game.away_scorers, away),
    ].sort((a, b) => b.time.elapsed - a.time.elapsed),
  };
}

function normalizeWorldCup26Group(group, teams) {
  const teamMap = mapById(teams);
  const rows = Array.isArray(group.teams) ? group.teams : [];
  const groupName = cleanString(group.name) || "Group";

  return rows.map((row, index) => {
    const teamSource = teamMap.get(readInt(row.team_id, 0));
    return {
      rank: index + 1,
      team: normalizeWorldCup26Team(teamSource || { id: row.team_id }),
      group: groupName.startsWith("Group") ? groupName : `Group ${groupName}`,
      points: readInt(row.pts, 0),
      goalsDiff: readInt(row.gd, 0),
      form: null,
      status: "same",
      description: null,
      all: {
        played: readInt(row.mp, 0),
        win: readInt(row.w, 0),
        draw: readInt(row.d, 0),
        lose: readInt(row.l, 0),
        goals: {
          for: readInt(row.gf, 0),
          against: readInt(row.ga, 0),
        },
      },
      home: null,
      away: null,
      update: null,
    };
  });
}

function normalizeWorldCup26Team(team) {
  const id = readInt(team && team.id, 0);
  return {
    id,
    name: cleanString(team && team.name_en) || "TBD",
    code: cleanString(team && (team.fifa_code || team.iso2)),
    country: cleanString(team && team.name_en),
    logo: assetUrl(team && team.flag),
  };
}

function teamFromGame(game, side, teamMap) {
  const teamId = readInt(game[`${side}_team_id`], 0);
  const source = teamMap.get(teamId);
  const fallbackName =
    cleanString(game[`${side}_team_name_en`]) ||
    cleanString(game[`${side}_team_label`]) ||
    "TBD";

  if (!source) {
    return {
      id: teamId,
      name: fallbackName,
      code: null,
      country: null,
      logo: null,
      winner: null,
    };
  }

  return {
    ...normalizeWorldCup26Team(source),
    name: cleanString(source.name_en) || fallbackName,
    winner: null,
  };
}

function worldCup26Round(game) {
  const group = cleanString(game.group);
  const matchday = cleanString(game.matchday);
  const type = cleanString(game.type);

  if (group) {
    const groupLabel = group.startsWith("Group") ? group : `Group ${group}`;
    return matchday ? `${groupLabel} - Matchday ${matchday}` : groupLabel;
  }

  if (!type) {
    return "World Cup";
  }

  return type
    .split(/[_-]+/)
    .filter(Boolean)
    .map((part) => part[0].toUpperCase() + part.slice(1).toLowerCase())
    .join(" ");
}

function statusFromWorldCup26(game) {
  const elapsedText = String(game.time_elapsed || "").trim().toLowerCase();
  const elapsed = readInt(elapsedText, 0);

  if (isTrue(game.finished)) {
    return {
      long: "Match Finished",
      short: "FT",
      elapsed: elapsed > 0 ? elapsed : 90,
      extra: null,
    };
  }

  if (!elapsedText || elapsedText === "notstarted") {
    return {
      long: "Not Started",
      short: "NS",
      elapsed: 0,
      extra: null,
    };
  }

  if (elapsedText === "halftime" || elapsedText === "ht") {
    return {
      long: "Halftime",
      short: "HT",
      elapsed: 45,
      extra: null,
    };
  }

  if (elapsed > 0) {
    return {
      long: "Live",
      short: elapsed <= 45 ? "1H" : "2H",
      elapsed,
      extra: null,
    };
  }

  return {
    long: "Live",
    short: "LIVE",
    elapsed: 0,
    extra: null,
  };
}

function scorerEvents(value, team) {
  const scorers = scorerList(value);
  return scorers
    .map((scorer) => scorerEvent(scorer, team))
    .filter(Boolean);
}

function scorerEvent(value, team) {
  const text = cleanString(value);
  if (!text) {
    return null;
  }

  const minuteMatch = text.match(/(\d{1,3})(?:\+(\d{1,2}))?['’]?/);
  if (!minuteMatch) {
    return null;
  }

  const minute = readInt(minuteMatch[1], 0);
  if (minute <= 0) {
    return null;
  }

  const extra = minuteMatch[2] ? readInt(minuteMatch[2], 0) : null;
  const playerName = cleanString(
    text
      .replace(minuteMatch[0], "")
      .replace(/\(.*?\)/g, "")
      .replace(/-/g, " "),
  );

  return {
    time: {
      elapsed: minute,
      extra,
    },
    team,
    player: {
      id: null,
      name: playerName || text,
    },
    assist: {
      id: null,
      name: null,
    },
    type: "Goal",
    detail: text.toLowerCase().includes("pen") ? "Penalty" : "Normal Goal",
    comments: text,
  };
}

function scorerList(value) {
  if (Array.isArray(value)) {
    return value;
  }

  const text = cleanString(value);
  if (!text || text.toLowerCase() === "null") {
    return [];
  }

  return text
    .split(/[,;]+/)
    .map((item) => item.trim())
    .filter(Boolean);
}

function filterWorldCup26Fixtures(fixtures, data) {
  const round = cleanOptional(data.round, /^[A-Za-z0-9 ._-]+$/);
  const date = cleanOptional(data.date, /^\d{4}-\d{2}-\d{2}$/);
  const from = cleanOptional(data.from, /^\d{4}-\d{2}-\d{2}$/);
  const to = cleanOptional(data.to, /^\d{4}-\d{2}-\d{2}$/);

  return fixtures.filter((fixture) => {
    const fixtureDate = String(fixture.fixture.date || "").slice(0, 10);
    if (round && fixture.league.round !== round) {
      return false;
    }
    if (date && fixtureDate !== date) {
      return false;
    }
    if (from && fixtureDate < from) {
      return false;
    }
    if (to && fixtureDate > to) {
      return false;
    }
    return true;
  });
}

function mapById(items) {
  const map = new Map();
  for (const item of Array.isArray(items) ? items : []) {
    const id = readInt(item && item.id, 0);
    if (id > 0) {
      map.set(id, item);
    }
  }
  return map;
}

function stadiumCity(stadium) {
  if (!stadium) {
    return null;
  }

  const parts = [
    cleanString(stadium.city_en),
    cleanString(stadium.country_en),
  ].filter(Boolean);
  return parts.length ? parts.join(", ") : null;
}

function worldCup26DateToIso(value) {
  const text = cleanString(value);
  const match = text.match(
    /^(\d{1,2})\/(\d{1,2})\/(\d{4})\s+(\d{1,2}):(\d{2})$/,
  );
  if (!match) {
    return new Date().toISOString();
  }

  const [, month, day, year, hour, minute] = match;
  return `${year}-${pad2(month)}-${pad2(day)}T${pad2(hour)}:${pad2(minute)}:00`;
}

function isLiveStatus(value) {
  return ["1H", "HT", "2H", "ET", "P", "BT", "LIVE"].includes(
    String(value || "").toUpperCase(),
  );
}

function isTrue(value) {
  return String(value || "").trim().toLowerCase() === "true";
}

function nullableInt(value) {
  if (value === null || value === undefined || value === "") {
    return null;
  }
  const parsed = Number.parseInt(String(value), 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function readInt(value, fallback) {
  if (value === null || value === undefined || value === "") {
    return fallback;
  }

  const parsed = Number.parseInt(String(value), 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function cleanString(value) {
  if (value === null || value === undefined) {
    return null;
  }

  const text = String(value).trim();
  if (!text || text.toLowerCase() === "null") {
    return null;
  }
  return text;
}

function cleanText(value, pattern, fallback) {
  const text = String(value || "").trim();
  return pattern.test(text) ? text : fallback;
}

function cleanOptional(value, pattern) {
  if (value === null || value === undefined || value === "") {
    return undefined;
  }

  const text = String(value).trim();
  return pattern.test(text) ? text : undefined;
}

function cleanParams(params) {
  return Object.fromEntries(
    Object.entries(params).filter(([, value]) => value !== undefined),
  );
}

function pad2(value) {
  return String(value).padStart(2, "0");
}

function assetUrl(value) {
  const text = cleanString(value);
  if (!text) {
    return null;
  }
  if (/^https?:\/\//i.test(text)) {
    return text;
  }
  return text.startsWith("/")
    ? `${WORLD_CUP_26_BASE_URL}${text}`
    : `${WORLD_CUP_26_BASE_URL}/${text}`;
}

function envelope(provider, resource, data, response) {
  return {
    provider,
    get: resource,
    parameters: data || {},
    errors: [],
    results: Array.isArray(response) ? response.length : 0,
    paging: {
      current: 1,
      total: 1,
    },
    response,
  };
}

async function safeJson(response) {
  try {
    return await response.json();
  } catch (_) {
    return {};
  }
}
