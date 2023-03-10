-- People
CREATE TABLE "people" (
    "id" TEXT NOT NULL GENERATED ALWAYS AS ("githubHandle") STORED,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "biography" TEXT,
    "website" TEXT,
    "githubHandle" TEXT NOT NULL CONSTRAINT "github_handle_length" CHECK (char_length("githubHandle") <= 39),
    "twitterHandle" TEXT CONSTRAINT "twitter_handle_length" CHECK (
        "twitterHandle" IS NULL
        OR (
            char_length("twitterHandle") >= 4
            AND char_length("twitterHandle") <= 15
        )
    ),
    "youtubeHandle" TEXT CONSTRAINT "youtube_handle_length" CHECK (
        "youtubeHandle" IS NULL
        OR (
            char_length("youtubeHandle") >= 3
            AND char_length("youtubeHandle") <= 30
        )
    ),
    CONSTRAINT "person_id" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "person_github_handle" ON "people"("githubHandle");
CREATE UNIQUE INDEX "person_twitter_handle" ON "people"("twitterHandle");
CREATE UNIQUE INDEX "person_youtube_handle" ON "people"("youtubeHandle");
CREATE UNIQUE INDEX "person_email" ON "people"("email");

-- Shows
CREATE TABLE "shows" (
    "id" TEXT PRIMARY KEY,
    "name" TEXT NOT NULL
);

CREATE UNIQUE INDEX "show_name" ON "shows"("name");

-- Show Hosts Function Table
CREATE TABLE "show_hosts" (
    "showId" TEXT NOT NULL REFERENCES "shows"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    "personId" TEXT NOT NULL REFERENCES "people"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "show_hosts_id" PRIMARY KEY ("showId", "personId")
);

-- Hasura Flattening Views
CREATE VIEW show_hosts_view AS
SELECT "showId",
    people.*
FROM show_hosts
    LEFT JOIN people ON show_hosts."personId" = people.id;

CREATE VIEW host_shows_view AS
SELECT "personId",
    shows.*
FROM show_hosts
    LEFT JOIN shows ON show_hosts."showId" = shows.id;


-- Technologies
CREATE TABLE "technologies" (
    "id" TEXT PRIMARY KEY,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "website" TEXT NOT NULL,
    "openSource" BOOLEAN NOT NULL DEFAULT FALSE,
    "repository" TEXT NOT NULL,
    "documentation" TEXT NOT NULL,
    "twitterHandle" TEXT CHECK (
        "twitterHandle" IS NULL
        OR (
            char_length("twitterHandle") >= 4
            AND char_length("twitterHandle") <= 15
        )
    ),
    "youtubeHandle" TEXT CHECK (
        "youtubeHandle" IS NULL
        OR (
            char_length("youtubeHandle") >= 3
            AND char_length("youtubeHandle") <= 30
        )
    )
);

-- Episodes
CREATE TYPE "chapter" AS ("time" INTERVAL, "title" TEXT);

CREATE TABLE "episodes" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "showId" TEXT NOT NULL REFERENCES shows("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    "live" BOOLEAN NOT NULL DEFAULT true,
    "scheduledFor" TIMESTAMP,
    CONSTRAINT is_live CHECK (
        (NOT "live")
        OR ("scheduledFor" IS NOT NULL)
    ),
    "startedAt" TIMESTAMP,
    "finishedAt" TIMESTAMP,
    "youtubeId" TEXT,
    "youtubeCategory" INTEGER,
    "chapters" chapter [] DEFAULT array []::chapter [],
    "links" TEXT [] DEFAULT array []::TEXT []
);


-- Episode Guests
CREATE TABLE "episode_guests" (
    "episodeId" TEXT NOT NULL REFERENCES "episodes"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    "personId" TEXT NOT NULL REFERENCES "people"("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "episode_guests_id" PRIMARY KEY ("episodeId", "personId")
);

-- Hasura Flattening Views
CREATE VIEW episode_guests_view AS
SELECT "episodeId",
    people.*
FROM episode_guests
    LEFT JOIN people ON episode_guests."personId" = people.id;

CREATE VIEW guest_episodes_view AS
SELECT "personId",
    episodes.*
FROM episode_guests
    LEFT JOIN episodes ON episode_guests."episodeId" = episodes.id;
