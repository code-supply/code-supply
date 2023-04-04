import Config

config :hosting, Hosting.Repo,
  socket_dir: "/tmp/cloudsql/code-supply:europe-west1:shared-belgium/",
  database: "hosting",
  username: "hosting",
  password:
    System.get_env("PASSWORD") ||
      raise("Missing PASSWORD"),
  pool_size: 1
