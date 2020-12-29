import Config

config :site_operator,
  affiliate_site_image:
    System.get_env("AFFILIATE_SITE_IMAGE") ||
      raise("Must set AFFILIATE_SITE_IMAGE for this operator to use for its sites!")
