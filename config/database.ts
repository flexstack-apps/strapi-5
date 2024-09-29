import path from "path";

export default ({ env }) => {
	const client = env("DATABASE_CLIENT", "postgres");
	const connections = {
		postgres: {
			connection: {
				connectionString: env(
					"DATABASE_URL",
					`postgresql://${env("DATABASE_USERNAME", "strapi")}:${encodeURIComponent(env("DATABASE_PASSWORD", "strapi"))}@${env("DATABASE_HOST", "localhost")}:${env.int("DATABASE_PORT", 5432)}/${env("DATABASE_NAME", "strapi")}?search_path=${env("DATABASE_SCHEMA", "public")}`,
				),
			},
			pool: {
				min: env.int("DATABASE_POOL_MIN", 2),
				max: env.int("DATABASE_POOL_MAX", 10),
			},
		},
	};

	return {
		connection: {
			client,
			...connections[client],
			acquireConnectionTimeout: env.int("DATABASE_CONNECTION_TIMEOUT", 60000),
		},
	};
};
