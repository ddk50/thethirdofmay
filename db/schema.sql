CREATE TABLE "posts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "caption" varchar(255) NOT NULL, "body" text NOT NULL, "compiled_body" text, "published" boolean DEFAULT 'f' NOT NULL, "created_at" datetime, "updated_at" datetime);

CREATE TABLE "taggingposts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "post_id" integer NOT NULL, "tag_id" integer NOT NULL, "created_at" datetime, "updated_at" datetime);

CREATE TABLE "tags" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) NOT NULL, "created_at" datetime, "updated_at" datetime);
