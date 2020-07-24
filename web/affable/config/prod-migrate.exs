import Config

config :affable, Affable.Repo,
  socket_dir: "/tmp/cloudsql=tcp:5432/code-supply:europe-west2:shared/",
  database: "affable",
  username: "affable",
  password:
    System.get_env("PASSWORD") ||
      raise("Missing PASSWORD"),
  pool_size: 1
