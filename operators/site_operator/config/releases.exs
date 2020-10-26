import Config

config :site_operator,
  affiliate_site_image:
    System.get_env("AFFILIATE_SITE_IMAGE") ||
      raise("Must set AFFILIATE_SITE_IMAGE for this operator to use for its sites!")
      |> String.trim("\n"),
  distribution_cookie:
    System.get_env("SITE_DISTRIBUTION_COOKIE") ||
      raise("Must set SITE_DISTRIBUTION_COOKIE for this operator to use for its sites!")
