{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    bcrypt_elixir = buildMix rec {
      name = "bcrypt_elixir";
      version = "3.0.1";

      src = fetchHex {
        pkg = "bcrypt_elixir";
        version = "${version}";
        sha256 = "486bb95efb645d1efc6794c1ddd776a186a9a713abf06f45708a6ce324fb96cf";
      };

      beamDeps = [ comeonin elixir_make ];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "1.0.0";

      src = fetchHex {
        pkg = "bunt";
        version = "${version}";
        sha256 = "dc5f86aa08a5f6fa6b8096f0735c4e76d54ae5c9fa2c143e5a1fc7c1cd9bb6b5";
      };

      beamDeps = [];
    };

    castore = buildMix rec {
      name = "castore";
      version = "0.1.22";

      src = fetchHex {
        pkg = "castore";
        version = "${version}";
        sha256 = "c17576df47eb5aa1ee40cc4134316a99f5cad3e215d5c77b8dd3cfef12a22cac";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.12.0";

      src = fetchHex {
        pkg = "certifi";
        version = "${version}";
        sha256 = "ee68d85df22e554040cdb4be100f33873ac6051387baf6a8f6ce82272340ff1c";
      };

      beamDeps = [];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.3.3";

      src = fetchHex {
        pkg = "comeonin";
        version = "${version}";
        sha256 = "3e38c9c2cb080828116597ca8807bb482618a315bfafd98c90bc22a821cc84df";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "connection";
        version = "${version}";
        sha256 = "722c1eb0a418fbe91ba7bd59a47e28008a189d47e37e0e7bb85585a016b2869c";
      };

      beamDeps = [];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.10.0";

      src = fetchHex {
        pkg = "cowboy";
        version = "${version}";
        sha256 = "3afdccb7183cc6f143cb14d3cf51fa00e53db9ec80cdcd525482f5e99bc41d6b";
      };

      beamDeps = [ cowlib ranch ];
    };

    cowboy_telemetry = buildRebar3 rec {
      name = "cowboy_telemetry";
      version = "0.4.0";

      src = fetchHex {
        pkg = "cowboy_telemetry";
        version = "${version}";
        sha256 = "7d98bac1ee4565d31b62d59f8823dfd8356a169e7fcbb83831b8a5397404c9de";
      };

      beamDeps = [ cowboy telemetry ];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.12.1";

      src = fetchHex {
        pkg = "cowlib";
        version = "${version}";
        sha256 = "163b73f6367a7341b33c794c4e88e7dbfe6498ac42dcd69ef44c5bc5507c8db0";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.7.2";

      src = fetchHex {
        pkg = "credo";
        version = "${version}";
        sha256 = "dd15d6fbc280f6cf9b269f41df4e4992dee6615939653b164ef951f60afcb68e";
      };

      beamDeps = [ bunt file_system jason ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.5.0";

      src = fetchHex {
        pkg = "db_connection";
        version = "${version}";
        sha256 = "c92d5ba26cd69ead1ff7582dbb860adeedfff39774105a4f1c92cbb654b55aa2";
      };

      beamDeps = [ telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.1.1";

      src = fetchHex {
        pkg = "decimal";
        version = "${version}";
        sha256 = "53cfe5f497ed0e7771ae1a475575603d77425099ba5faef9394932b35020ffcc";
      };

      beamDeps = [];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.3.0";

      src = fetchHex {
        pkg = "dialyxir";
        version = "${version}";
        sha256 = "00b2a4bcd6aa8db9dcb0b38c1225b7277dca9bc370b6438715667071a304696f";
      };

      beamDeps = [ erlex ];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.9.6";

      src = fetchHex {
        pkg = "ecto";
        version = "${version}";
        sha256 = "df17bc06ba6f78a7b764e4a14ef877fe5f4499332c5a105ace11fe7013b72c84";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.9.2";

      src = fetchHex {
        pkg = "ecto_sql";
        version = "${version}";
        sha256 = "1eb5eeb4358fdbcd42eac11c1fbd87e3affd7904e639d77903c1358b2abd3f70";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.7.7";

      src = fetchHex {
        pkg = "elixir_make";
        version = "${version}";
        sha256 = "5bc19fff950fad52bbe5f211b12db9ec82c6b34a9647da0c2224b8b8464c7e6c";
      };

      beamDeps = [ castore ];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "erlex";
        version = "${version}";
        sha256 = "2ed2e25711feb44d52b17d2780eabf998452f6efda104877a3881c2f8c0c0c75";
      };

      beamDeps = [];
    };

    esbuild = buildMix rec {
      name = "esbuild";
      version = "0.7.1";

      src = fetchHex {
        pkg = "esbuild";
        version = "${version}";
        sha256 = "66661cdf70b1378ee4dc16573fcee67750b59761b2605a0207c267ab9d19f13c";
      };

      beamDeps = [ castore ];
    };

    expo = buildMix rec {
      name = "expo";
      version = "0.4.1";

      src = fetchHex {
        pkg = "expo";
        version = "${version}";
        sha256 = "2ff7ba7a798c8c543c12550fa0e2cbc81b95d4974c65855d8d15ba7b37a1ce47";
      };

      beamDeps = [];
    };

    fast_html = buildMix rec {
      name = "fast_html";
      version = "2.3.0";

      src = fetchHex {
        pkg = "fast_html";
        version = "${version}";
        sha256 = "f18e3c7668f82d3ae0b15f48d48feeb257e28aa5ab1b0dbf781c7312e5da029d";
      };

      beamDeps = [ elixir_make nimble_pool ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "file_system";
        version = "${version}";
        sha256 = "41195edbfb562a593726eda3b3e8b103a309b733ad25f3d642ba49696bf715dc";
      };

      beamDeps = [];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.17.0";

      src = fetchHex {
        pkg = "finch";
        version = "${version}";
        sha256 = "8d014a661bb6a437263d4b5abf0bcbd3cf0deb26b1e8596f2a271d22e48934c7";
      };

      beamDeps = [ castore mime mint nimble_options nimble_pool telemetry ];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.35.3";

      src = fetchHex {
        pkg = "floki";
        version = "${version}";
        sha256 = "6d9f07f3fc76599f3b66c39f4a81ac62c8f4d9631140268db92aacad5d0e56d4";
      };

      beamDeps = [];
    };

    gcs_signed_url = buildMix rec {
      name = "gcs_signed_url";
      version = "0.4.5";

      src = fetchHex {
        pkg = "gcs_signed_url";
        version = "${version}";
        sha256 = "1fb58e2f9dcf07fae4baf906c37426eeddcf40a6dac3dcd5182308be05f5e0e0";
      };

      beamDeps = [ httpoison jason ];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.22.3";

      src = fetchHex {
        pkg = "gettext";
        version = "${version}";
        sha256 = "935f23447713954a6866f1bb28c3a878c4c011e802bcd68a726f5e558e4b64bd";
      };

      beamDeps = [ expo ];
    };

    google_api_storage = buildMix rec {
      name = "google_api_storage";
      version = "0.34.0";

      src = fetchHex {
        pkg = "google_api_storage";
        version = "${version}";
        sha256 = "b343f2f1688acd2e8a2302bed399a24d93626f8e8c809b358214bb0fb7d2669a";
      };

      beamDeps = [ google_gax ];
    };

    google_gax = buildMix rec {
      name = "google_gax";
      version = "0.4.1";

      src = fetchHex {
        pkg = "google_gax";
        version = "${version}";
        sha256 = "aef7dce7e04840c0e611f962475e3223d27d50ebd5e7d8e9e963c5e9e3b1ca79";
      };

      beamDeps = [ mime poison tesla ];
    };

    goth = buildMix rec {
      name = "goth";
      version = "1.4.1";

      src = fetchHex {
        pkg = "goth";
        version = "${version}";
        sha256 = "c906981879048d9e0d6474d347092f2cbf55b238de33b4fe740a0d3aa126f901";
      };

      beamDeps = [ finch jason jose ];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.20.1";

      src = fetchHex {
        pkg = "hackney";
        version = "${version}";
        sha256 = "fe9094e5f1a2a2c0a7d10918fee36bfec0ec2a979994cff8cfe8058cd9af38e3";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    hammox = buildMix rec {
      name = "hammox";
      version = "0.7.0";

      src = fetchHex {
        pkg = "hammox";
        version = "${version}";
        sha256 = "5e228c4587f23543f90c11394957878178c489fad46da421c37ca696e37dd91b";
      };

      beamDeps = [ mox ordinal telemetry ];
    };

    hashids = buildMix rec {
      name = "hashids";
      version = "2.1.0";

      src = fetchHex {
        pkg = "hashids";
        version = "${version}";
        sha256 = "172163b1642d415881ef1c6e1f1be12d4e92b0711d5bbbd8854f82a1ce32d60b";
      };

      beamDeps = [];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "0.1.2";

      src = fetchHex {
        pkg = "hpax";
        version = "${version}";
        sha256 = "2c87843d5a23f5f16748ebe77969880e29809580efdaccd615cd3bed628a8c13";
      };

      beamDeps = [];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "1.8.2";

      src = fetchHex {
        pkg = "httpoison";
        version = "${version}";
        sha256 = "2bb350d26972e30c96e2ca74a1aaf8293d61d0742ff17f01e0279fef11599921";
      };

      beamDeps = [ hackney ];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "idna";
        version = "${version}";
        sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
      };

      beamDeps = [ unicode_util_compat ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.1";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "fbb01ecdfd565b56261302f7e1fcc27c4fb8f32d56eab74db621fc154604a7a1";
      };

      beamDeps = [ decimal ];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.6";

      src = fetchHex {
        pkg = "jose";
        version = "${version}";
        sha256 = "6275cb75504f9c1e60eeacb771adfeee4905a9e182103aa59b53fed651ff9738";
      };

      beamDeps = [];
    };

    k8s = buildMix rec {
      name = "k8s";
      version = "1.2.0";

      src = fetchHex {
        pkg = "k8s";
        version = "${version}";
        sha256 = "f12e830d82c3089b5694026ce4f736c0384593115985e2f7bd3f21153c3b0672";
      };

      beamDeps = [ castore httpoison jason telemetry websockex yaml_elixir ];
    };

    libcluster = buildMix rec {
      name = "libcluster";
      version = "3.3.3";

      src = fetchHex {
        pkg = "libcluster";
        version = "${version}";
        sha256 = "7c0a2275a0bb83c07acd17dab3c3bfb4897b145106750eeccc62d302e3bdfee5";
      };

      beamDeps = [ jason ];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "metrics";
        version = "${version}";
        sha256 = "69b09adddc4f74a40716ae54d140f93beb0fb8978d8636eaded0c31b6f099f16";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "1.6.0";

      src = fetchHex {
        pkg = "mime";
        version = "${version}";
        sha256 = "31a1a8613f8321143dde1dafc36006a17d28d02bdfecb9e95a880fa7aabd19a7";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "mimerl";
        version = "${version}";
        sha256 = "f278585650aa581986264638ebf698f8bb19df297f66ad91b18910dfc6e19323";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.5.2";

      src = fetchHex {
        pkg = "mint";
        version = "${version}";
        sha256 = "d77d9e9ce4eb35941907f1d3df38d8f750c357865353e21d335bdcdf6d892a02";
      };

      beamDeps = [ castore hpax ];
    };

    mix_test_watch = buildMix rec {
      name = "mix_test_watch";
      version = "1.1.0";

      src = fetchHex {
        pkg = "mix_test_watch";
        version = "${version}";
        sha256 = "52b6b1c476cbb70fd899ca5394506482f12e5f6b0d6acff9df95c7f1e0812ec3";
      };

      beamDeps = [ file_system ];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.0.2";

      src = fetchHex {
        pkg = "mox";
        version = "${version}";
        sha256 = "f9864921b3aaf763c8741b5b8e6f908f44566f1e427b2630e89e9a73b981fef2";
      };

      beamDeps = [];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "1.1.0";

      src = fetchHex {
        pkg = "nimble_options";
        version = "${version}";
        sha256 = "8bbbb3941af3ca9acc7835f5655ea062111c9c27bcac53e004460dfd19008a99";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "0.2.6";

      src = fetchHex {
        pkg = "nimble_pool";
        version = "${version}";
        sha256 = "1c715055095d3f2705c4e236c18b618420a35490da94149ff8b580a2144f653f";
      };

      beamDeps = [];
    };

    ordinal = buildMix rec {
      name = "ordinal";
      version = "0.2.0";

      src = fetchHex {
        pkg = "ordinal";
        version = "${version}";
        sha256 = "defca8f10dee9f03a090ed929a595303252700a9a73096b6f2f8d88341690d65";
      };

      beamDeps = [];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.4.1";

      src = fetchHex {
        pkg = "parse_trans";
        version = "${version}";
        sha256 = "620a406ce75dada827b82e453c19cf06776be266f5a67cff34e1ef2cbb60e49a";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.7.7";

      src = fetchHex {
        pkg = "phoenix";
        version = "${version}";
        sha256 = "8966e15c395e5e37591b6ed0bd2ae7f48e961f0f60ac4c733f9566b519453085";
      };

      beamDeps = [ castore jason phoenix_pubsub phoenix_template phoenix_view plug plug_cowboy plug_crypto telemetry websock_adapter ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.4.2";

      src = fetchHex {
        pkg = "phoenix_ecto";
        version = "${version}";
        sha256 = "70242edd4601d50b69273b057ecf7b684644c19ee750989fd555625ae4ce8f5d";
      };

      beamDeps = [ ecto phoenix_html plug ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "3.3.1";

      src = fetchHex {
        pkg = "phoenix_html";
        version = "${version}";
        sha256 = "bed1906edd4906a15fd7b412b85b05e521e1f67c9a85418c55999277e553d0d3";
      };

      beamDeps = [ plug ];
    };

    phoenix_live_dashboard = buildMix rec {
      name = "phoenix_live_dashboard";
      version = "0.8.0";

      src = fetchHex {
        pkg = "phoenix_live_dashboard";
        version = "${version}";
        sha256 = "87785a54474fed91a67a1227a741097eb1a42c2e49d3c0d098b588af65cd410d";
      };

      beamDeps = [ ecto mime phoenix_live_view telemetry_metrics ];
    };

    phoenix_live_reload = buildMix rec {
      name = "phoenix_live_reload";
      version = "1.4.1";

      src = fetchHex {
        pkg = "phoenix_live_reload";
        version = "${version}";
        sha256 = "9bffb834e7ddf08467fe54ae58b5785507aaba6255568ae22b4d46e2bb3615ab";
      };

      beamDeps = [ file_system phoenix ];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "0.19.5";

      src = fetchHex {
        pkg = "phoenix_live_view";
        version = "${version}";
        sha256 = "b2eaa0dd3cfb9bd7fb949b88217df9f25aed915e986a28ad5c8a0d054e7ca9d3";
      };

      beamDeps = [ jason phoenix phoenix_html phoenix_template phoenix_view telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.3";

      src = fetchHex {
        pkg = "phoenix_pubsub";
        version = "${version}";
        sha256 = "bba06bc1dcfd8cb086759f0edc94a8ba2bc8896d5331a1e2c2902bf8e36ee502";
      };

      beamDeps = [];
    };

    phoenix_template = buildMix rec {
      name = "phoenix_template";
      version = "1.0.3";

      src = fetchHex {
        pkg = "phoenix_template";
        version = "${version}";
        sha256 = "16f4b6588a4152f3cc057b9d0c0ba7e82ee23afa65543da535313ad8d25d8e2c";
      };

      beamDeps = [ phoenix_html ];
    };

    phoenix_view = buildMix rec {
      name = "phoenix_view";
      version = "2.0.2";

      src = fetchHex {
        pkg = "phoenix_view";
        version = "${version}";
        sha256 = "a929e7230ea5c7ee0e149ffcf44ce7cf7f4b6d2bfe1752dd7c084cdff152d36f";
      };

      beamDeps = [ phoenix_html phoenix_template ];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.15.3";

      src = fetchHex {
        pkg = "plug";
        version = "${version}";
        sha256 = "cc4365a3c010a56af402e0809208873d113e9c38c401cabd88027ef4f5c01fd2";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.7.0";

      src = fetchHex {
        pkg = "plug_cowboy";
        version = "${version}";
        sha256 = "d85444fb8aa1f2fc62eabe83bbe387d81510d773886774ebdcb429b3da3c1a4a";
      };

      beamDeps = [ cowboy cowboy_telemetry plug ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.5";

      src = fetchHex {
        pkg = "plug_crypto";
        version = "${version}";
        sha256 = "26549a1d6345e2172eb1c233866756ae44a9609bd33ee6f99147ab3fd87fd842";
      };

      beamDeps = [];
    };

    poison = buildMix rec {
      name = "poison";
      version = "4.0.1";

      src = fetchHex {
        pkg = "poison";
        version = "${version}";
        sha256 = "ba8836feea4b394bb718a161fc59a288fe0109b5006d6bdf97b6badfcf6f0f25";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.16.5";

      src = fetchHex {
        pkg = "postgrex";
        version = "${version}";
        sha256 = "edead639dc6e882618c01d8fc891214c481ab9a3788dfe38dd5e37fd1d5fb2e8";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.0";

      src = fetchHex {
        pkg = "ranch";
        version = "${version}";
        sha256 = "49fbcfd3682fab1f5d109351b61257676da1a2fdbe295904176d5e521a2ddfe5";
      };

      beamDeps = [];
    };

    size = buildMix rec {
      name = "size";
      version = "0.1.1";

      src = fetchHex {
        pkg = "size";
        version = "${version}";
        sha256 = "1449f569b6dbd400b52ae50df7e0487133192b0fe6f4fd3617f27c1e4848fe1a";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.7";

      src = fetchHex {
        pkg = "ssl_verify_fun";
        version = "${version}";
        sha256 = "fe4c190e8f37401d30167c8c405eda19469f34577987c76dde613e838bbc67f8";
      };

      beamDeps = [];
    };

    swoosh = buildMix rec {
      name = "swoosh";
      version = "1.15.1";

      src = fetchHex {
        pkg = "swoosh";
        version = "${version}";
        sha256 = "aa4e794bd39529f3d7e9cfd406ff1bbc422b9120e2a7ad38dfdf9b469d0c91f6";
      };

      beamDeps = [ cowboy finch hackney jason mime plug plug_cowboy telemetry ];
    };

    tailwind = buildMix rec {
      name = "tailwind";
      version = "0.2.1";

      src = fetchHex {
        pkg = "tailwind";
        version = "${version}";
        sha256 = "e8a13f6107c95f73e58ed1b4221744e1eb5a093cd1da244432067e19c8c9a277";
      };

      beamDeps = [ castore ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.2.1";

      src = fetchHex {
        pkg = "telemetry";
        version = "${version}";
        sha256 = "dad9ce9d8effc621708f99eac538ef1cbe05d6a874dd741de2e689c47feafed5";
      };

      beamDeps = [];
    };

    telemetry_metrics = buildMix rec {
      name = "telemetry_metrics";
      version = "0.6.1";

      src = fetchHex {
        pkg = "telemetry_metrics";
        version = "${version}";
        sha256 = "7be9e0871c41732c233be71e4be11b96e56177bf15dde64a8ac9ce72ac9834c6";
      };

      beamDeps = [ telemetry ];
    };

    telemetry_poller = buildRebar3 rec {
      name = "telemetry_poller";
      version = "1.0.0";

      src = fetchHex {
        pkg = "telemetry_poller";
        version = "${version}";
        sha256 = "b3a24eafd66c3f42da30fc3ca7dda1e9d546c12250a2d60d7b81d264fbec4f6e";
      };

      beamDeps = [ telemetry ];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.7.0";

      src = fetchHex {
        pkg = "tesla";
        version = "${version}";
        sha256 = "2e64f01ebfdb026209b47bc651a0e65203fcff4ae79c11efb73c4852b00dc313";
      };

      beamDeps = [ castore finch hackney jason mime mint poison telemetry ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "unicode_util_compat";
        version = "${version}";
        sha256 = "25eee6d67df61960cf6a794239566599b09e17e668d3700247bc498638152521";
      };

      beamDeps = [];
    };

    websock = buildMix rec {
      name = "websock";
      version = "0.5.2";

      src = fetchHex {
        pkg = "websock";
        version = "${version}";
        sha256 = "925f5de22fca6813dfa980fb62fd542ec43a2d1a1f83d2caec907483fe66ff05";
      };

      beamDeps = [];
    };

    websock_adapter = buildMix rec {
      name = "websock_adapter";
      version = "0.5.3";

      src = fetchHex {
        pkg = "websock_adapter";
        version = "${version}";
        sha256 = "cbe5b814c1f86b6ea002b52dd99f345aeecf1a1a6964e209d208fb404d930d3d";
      };

      beamDeps = [ plug plug_cowboy websock ];
    };

    websockex = buildMix rec {
      name = "websockex";
      version = "0.4.3";

      src = fetchHex {
        pkg = "websockex";
        version = "${version}";
        sha256 = "95f2e7072b85a3a4cc385602d42115b73ce0b74a9121d0d6dbbf557645ac53e4";
      };

      beamDeps = [];
    };

    yamerl = buildRebar3 rec {
      name = "yamerl";
      version = "0.10.0";

      src = fetchHex {
        pkg = "yamerl";
        version = "${version}";
        sha256 = "346adb2963f1051dc837a2364e4acf6eb7d80097c0f53cbdc3046ec8ec4b4e6e";
      };

      beamDeps = [];
    };

    yaml_elixir = buildMix rec {
      name = "yaml_elixir";
      version = "2.9.0";

      src = fetchHex {
        pkg = "yaml_elixir";
        version = "${version}";
        sha256 = "0cb0e7d4c56f5e99a6253ed1a670ed0e39c13fc45a6da054033928607ac08dfc";
      };

      beamDeps = [ yamerl ];
    };
  };
in self

