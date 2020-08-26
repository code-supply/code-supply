import Config

config :site_operator,
  distribution_cookie:
    System.get_env("SITE_DISTRIBUTION_COOKIE") ||
      raise("Must set SITE_DISTRIBUTION_COOKIE for this operator to use for its sites!")
