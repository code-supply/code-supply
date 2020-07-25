import Config

config :affable, Affable.Repo,
  socket_dir: "/tmp/cloudsql/code-supply:europe-west1:shared-belgium/",
  database: "affable",
  username: "affable",
  password:
    System.get_env("PASSWORD") ||
      raise("Missing PASSWORD"),
  pool_size: 1
