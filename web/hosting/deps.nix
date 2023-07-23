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
        pkg = "${name}";
        version = "${version}";
        sha256 = "1kwnzcjf6v4af12nzw5b2fksk1m1fvbxvhclczy1wpb4zdgbjss8";
      };

      beamDeps = [ comeonin elixir_make ];
    };

    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0lw3v9kwbbcy1v6ygziiky887gffwwmxvyg4r1v0zm71kzhcgxbs";
      };

      beamDeps = [];
    };

    castore = buildMix rec {
      name = "castore";
      version = "0.1.22";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1b1cl89fzkykimxwgm8mwb9wmxcrd8qk8hfc83pa2npb8zgpcxf1";
      };

      beamDeps = [];
    };

    certifi = buildRebar3 rec {
      name = "certifi";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ha6vmf5p3xlbf5w1msa89frhvfk535rnyfybz9wdmh6vdms8v96";
      };

      beamDeps = [];
    };

    comeonin = buildMix rec {
      name = "comeonin";
      version = "5.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pw4rhhsh8mwj26dkbxz2niih9j8pc3qijlpcl8jh208rg1cjf1y";
      };

      beamDeps = [];
    };

    connection = buildMix rec {
      name = "connection";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1746n8ba11amp1xhwzp38yfii2h051za8ndxlwdykyqqljq1wb3j";
      };

      beamDeps = [];
    };

    cowboy = buildErlangMk rec {
      name = "cowboy";
      version = "2.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0sqxqjdykxc2ai9cvkc0xjwkvr80z98wzlqlrd1z3iiw32vwrz9s";
      };

      beamDeps = [ cowlib ranch ];
    };

    cowboy_telemetry = buildRebar3 rec {
      name = "cowboy_telemetry";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pn90is3k9dq64wbijvzkqb6ldfqvwiqi7ymc8dx6ra5xv0vm63x";
      };

      beamDeps = [ cowboy telemetry ];
    };

    cowlib = buildRebar3 rec {
      name = "cowlib";
      version = "2.12.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1c4dgi8canscyjgddp22mjc69znvwy44wk3r7jrl2wvs6vv76fqn";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.5.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05zbqwzpai3257slw5ibblz6wazallc8ar1awq6y6r5xb3js6ljb";
      };

      beamDeps = [ bunt file_system jason ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04iwywfqf8k125yfvm084l1mp0bcv82mwih7xlpb7kx61xdw29y1";
      };

      beamDeps = [ connection telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k7z418b6cj977wswpxsk5844xrxc1smaiqsmrqpf3pdjzsfbksk";
      };

      beamDeps = [];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0qw4zyd86fjwsav744jvz1wpdbmy9nz645xqr9s1d1bs88v221v1";
      };

      beamDeps = [ erlex ];
    };

    earmark = buildMix rec {
      name = "earmark";
      version = "1.4.24";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0rvwvas06mv5z911ii8hvp79429xgasjp3vdflsdcahz4hpj894p";
      };

      beamDeps = [ earmark_parser ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.25";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07pmhgz3wzr34xi0l8pwd8kzxpmkwhsv5p93g9xpyi2r3ig9qx2n";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.9.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0k5p40cy6zxi3wm885amf78724zvb5a8chmpljzw1kdsiifi3wyl";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.9.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0w1zplm8ndf10dwxffg60iwzvbz3hyyiy761x91cvnwg6nsfxd8y";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    elixir_make = buildMix rec {
      name = "elixir_make";
      version = "0.7.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "11r8maaqnpp2an0i8s7b7vla4gs7b7g43kcyv203iyljbj6kxmn3";
      };

      beamDeps = [ castore ];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0x8c1j62y748ldvlh46sxzv5514rpzm809vxn594vd7y25by5lif";
      };

      beamDeps = [];
    };

    esbuild = buildMix rec {
      name = "esbuild";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ll7zvxhcyibd7qx3qrz9yq2pyqjbakavf4h2c0cpsy56zrg9saa";
      };

      beamDeps = [ castore ];
    };

    expo = buildMix rec {
      name = "expo";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wmbycv8mdfngxnn3c3bi8b3kx9md4n1p96p7yjpyz4bxj1idvd8";
      };

      beamDeps = [];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1p0myxmnjjds8bbg69dd6fvhk8q3n7lb78zd4qvmjajnzgdmw6a1";
      };

      beamDeps = [];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.14.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pd805jyd4qbpb2md3kw443325yqynpkpyr2iixb9zf432psqnal";
      };

      beamDeps = [ castore mime mint nimble_options nimble_pool telemetry ];
    };

    floki = buildMix rec {
      name = "floki";
      version = "0.33.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1ihjszkd5pbgzvp1rgvchzngn2p5n6h8ag141zrzs4sz2byka426";
      };

      beamDeps = [ html_entities ];
    };

    gcs_signed_url = buildMix rec {
      name = "gcs_signed_url";
      version = "0.4.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q70yl2vw21333axrhyslr0czpgf4rsc61prpbjgl1ygklpqxd8z";
      };

      beamDeps = [ httpoison jason ];
    };

    gettext = buildMix rec {
      name = "gettext";
      version = "0.22.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0pdcj2hmf9jgv40w3594lqksvbp9fnx98g8d1kwy73k6mf6mn45d";
      };

      beamDeps = [ expo ];
    };

    google_api_storage = buildMix rec {
      name = "google_api_storage";
      version = "0.34.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "16k6savhzfqlh8srp04cirpn54sdlacx7gh24f52xkcad3qz4hxk";
      };

      beamDeps = [ google_gax ];
    };

    google_gax = buildMix rec {
      name = "google_gax";
      version = "0.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0mxcp6bn53vpch7hiagx3j8kq90ik7gbd2yxd09b6fkmvpqkcpd9";
      };

      beamDeps = [ poison tesla ];
    };

    goth = buildMix rec {
      name = "goth";
      version = "1.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0z4k964yqz4nr4v4ss92rf7mv544p864yjpwfpxsgkbs18n6qclh";
      };

      beamDeps = [ finch jason jose ];
    };

    hackney = buildRebar3 rec {
      name = "hackney";
      version = "1.18.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13hja14kig5jnzcizpdghj68i88f0yd9wjdfjic9nzi98kzxmv54";
      };

      beamDeps = [ certifi idna metrics mimerl parse_trans ssl_verify_fun unicode_util_compat ];
    };

    hammox = buildMix rec {
      name = "hammox";
      version = "0.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "120xcjva9lwn1996lxm0zlw8wi0inwcih763b1fqiizi7k8cgr66";
      };

      beamDeps = [ mox ordinal ];
    };

    hashids = buildMix rec {
      name = "hashids";
      version = "2.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "02yn6b7a30jghpcbnnqxf6q94kidw4diyvhwxy0mhh9dcjqn688p";
      };

      beamDeps = [];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "0.1.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04wci9ifsfyd2pbcrnpgh2aq0a8fi1lpkrzb91kz3x93b8yq91rc";
      };

      beamDeps = [];
    };

    html_entities = buildMix rec {
      name = "html_entities";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1k7xyj0q38ms3n5hbn782pa6w1vgd6biwlxr4db6319l828a6fy5";
      };

      beamDeps = [];
    };

    httpoison = buildMix rec {
      name = "httpoison";
      version = "1.8.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q3r7v84zbyggqr35mpd689g4p205ja0iqi9j9mm2vcdcxnnl59m";
      };

      beamDeps = [ hackney ];
    };

    idna = buildRebar3 rec {
      name = "idna";
      version = "6.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sjcjibl34sprpf1dgdmzfww24xlyy34lpj7mhcys4j4i6vnwdwj";
      };

      beamDeps = [ unicode_util_compat ];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0891p2yrg3ri04p302cxfww3fi16pvvw1kh4r91zg85jhl87k8vr";
      };

      beamDeps = [ decimal ];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "115k981kfg9jmafgs16rybc5qah6p0zgvni3bdyfl0pyp8av5lyw";
      };

      beamDeps = [];
    };

    k8s = buildMix rec {
      name = "k8s";
      version = "1.1.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1sdl3m9057c2hdxl4l2wqqqv8yf1craid11i9w9m0f4mam3mzkk8";
      };

      beamDeps = [ castore httpoison jason telemetry yaml_elixir ];
    };

    libcluster = buildMix rec {
      name = "libcluster";
      version = "3.3.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19fqf5l0w6lg3x0i63c9vy4nhv7nxxcyvdy07y7zqw2n33l1qscb";
      };

      beamDeps = [ jason ];
    };

    metrics = buildRebar3 rec {
      name = "metrics";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "05lz15piphyhvvm3d1ldjyw0zsrvz50d2m5f2q3s8x2gvkfrmc39";
      };

      beamDeps = [];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0p50h0ki8ay5sraiqxiajgwy1829bvyagj65bj9wjny4cnin83fs";
      };

      beamDeps = [];
    };

    mimerl = buildRebar3 rec {
      name = "mimerl";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08wkw73dy449n68ssrkz57gikfzqk3vfnf264s31jn5aa1b5hy7j";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "106x9nmzi4ji5cqaddn76pxiyxdihk12z2qgszcdgd2rrjxsaxff";
      };

      beamDeps = [ castore hpax ];
    };

    mix_test_watch = buildMix rec {
      name = "mix_test_watch";
      version = "1.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01qs8kfbzz0rv9k7dsvsp6yhln8mri7x1ikj75vq9xh6if6mbb27";
      };

      beamDeps = [ file_system ];
    };

    mox = buildMix rec {
      name = "mox";
      version = "1.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1wpyh6wp76lyx0q2cys23rpmci4gj1pqwnqvfk467xxanchlk1pr";
      };

      beamDeps = [];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1q6wa2ljprybfb9w2zg0gbppiwsnimgw5kcvakdp3z8mp42gk9sd";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "0.2.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0gv59waa505mz2gi956sj1aa6844c65w2dp2qh2jfgsx15am0w8w";
      };

      beamDeps = [];
    };

    ordinal = buildMix rec {
      name = "ordinal";
      version = "0.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0r8dd50q7n7qyav9cc57m402f983adcrm4pdj2h077zf1pqsiz6y";
      };

      beamDeps = [];
    };

    parse_trans = buildRebar3 rec {
      name = "parse_trans";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "12w8ai6b5s6b4hnvkav7hwxd846zdd74r32f84nkcmjzi1vrbk87";
      };

      beamDeps = [];
    };

    phoenix = buildMix rec {
      name = "phoenix";
      version = "1.7.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0n91g6s7jbkb9rg3c5xdmihk7zyq5rsaji14mfby1l5l695skg0y";
      };

      beamDeps = [ castore jason phoenix_pubsub phoenix_template phoenix_view plug plug_cowboy plug_crypto telemetry websock_adapter ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.4.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1h9wnjmxns8y8dsr0r41ks66gscaqm7ivk4gsh5y07nkiralx1h9";
      };

      beamDeps = [ ecto phoenix_html plug ];
    };

    phoenix_html = buildMix rec {
      name = "phoenix_html";
      version = "3.3.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lyhagjpg4lran6431csgkvf28g50mdvh4mlsxgs21j9vmp91ldy";
      };

      beamDeps = [ plug ];
    };

    phoenix_live_dashboard = buildMix rec {
      name = "phoenix_live_dashboard";
      version = "0.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03a1rmjsz25mk38c1ls95qna9cby150sf9qjgak93vag8xa5ly47";
      };

      beamDeps = [ ecto mime phoenix_live_view telemetry_metrics ];
    };

    phoenix_live_reload = buildMix rec {
      name = "phoenix_live_reload";
      version = "1.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1aqm6sxy4ijd5gi8lmjmcaxal1smg2smibjlzrkq9w6xwwsbizwv";
      };

      beamDeps = [ file_system phoenix ];
    };

    phoenix_live_view = buildMix rec {
      name = "phoenix_live_view";
      version = "0.19.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "157m7n71wfgd5c4gj9n120gxz5m6qrx3y7iriy5jxwwpyaqprici";
      };

      beamDeps = [ jason phoenix phoenix_html phoenix_template phoenix_view telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1nfqrmbrq45if9pgk6g6vqiply2sxc40is3bfanphn7a3rnpqdl1";
      };

      beamDeps = [];
    };

    phoenix_template = buildMix rec {
      name = "phoenix_template";
      version = "1.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1vlkd4z2bxinczwcysydidpnh49rpxjihb5k3k4k8qr2yrwc0z8m";
      };

      beamDeps = [ phoenix_html ];
    };

    phoenix_view = buildMix rec {
      name = "phoenix_view";
      version = "2.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vykabqxyk08gkfm45zy5dnlnzygwx6g9z4z2h7fxix51qiyfad9";
      };

      beamDeps = [ phoenix_html phoenix_template ];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.14.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04wdyv6nma74bj1m49vkm2bc5mjf8zclfg957fng8g71hw0wabw4";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_cowboy = buildMix rec {
      name = "plug_cowboy";
      version = "2.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04v6xc4v741dr2y38j66fmcc4xc037dnaxzkj2vih6j53yif2dny";
      };

      beamDeps = [ cowboy cowboy_telemetry plug ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "1.2.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0hnqgzc3zas7j7wycgnkkdhaji5farkqccy2n4p1gqj5ccfrlm16";
      };

      beamDeps = [];
    };

    poison = buildMix rec {
      name = "poison";
      version = "4.0.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "098gdz7xzfmnjzgnnv80nl4h3zl8l9czqqd132vlnfabxbz3d25s";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.16.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1s5jbwfzsdsyvlwgx3bqlfwilj2c468wi3qxq0c2d23fvhwxdspd";
      };

      beamDeps = [ connection db_connection decimal jason ];
    };

    ranch = buildRebar3 rec {
      name = "ranch";
      version = "1.8.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rfz5ld54pkd2w25jadyznia2vb7aw9bclck21fizargd39wzys9";
      };

      beamDeps = [];
    };

    size = buildMix rec {
      name = "size";
      version = "0.1.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06py9141wz7j2wvgvx761wmijcvi93hgf3g55ash1m6vnrlzaj8l";
      };

      beamDeps = [];
    };

    ssl_verify_fun = buildRebar3 rec {
      name = "ssl_verify_fun";
      version = "1.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1026l1z1jh25z8bfrhaw0ryk5gprhrpnirq877zqhg253x3x5c5x";
      };

      beamDeps = [];
    };

    swoosh = buildMix rec {
      name = "swoosh";
      version = "1.9.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07ipsrp34s18c9zd5kglqsdc8z7gxa9aadsrklj0zf6azzrzzpvn";
      };

      beamDeps = [ cowboy finch hackney jason mime plug_cowboy telemetry ];
    };

    tailwind = buildMix rec {
      name = "tailwind";
      version = "0.1.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0w715aqql07sf6li85q0qfh9sw4lhra227rr4gpppa9bqincik21";
      };

      beamDeps = [ castore ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mgyx9zw92g6w8fp9pblm3b0bghwxwwcbslrixq23ipzisfwxnfs";
      };

      beamDeps = [];
    };

    telemetry_metrics = buildMix rec {
      name = "telemetry_metrics";
      version = "0.6.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1iilk2n75kn9i95fdp8mpxvn3rcn3ghln7p77cijqws13j3y1sbv";
      };

      beamDeps = [ telemetry ];
    };

    telemetry_poller = buildRebar3 rec {
      name = "telemetry_poller";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vjgxkxn9ll1gc6xd8jh4b0ldmg9l7fsfg7w63d44gvcssplx8mk";
      };

      beamDeps = [ telemetry ];
    };

    tesla = buildMix rec {
      name = "tesla";
      version = "1.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1pm9cq3bqv30xgv7aiybz2hzcx4i0xfm8bb9cpnx2wq9apvd8598";
      };

      beamDeps = [ castore finch hackney jason mime mint poison telemetry ];
    };

    unicode_util_compat = buildRebar3 rec {
      name = "unicode_util_compat";
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08952lw8cjdw8w171lv8wqbrxc4rcmb3jhkrdb7n06gngpbfdvi5";
      };

      beamDeps = [];
    };

    websock = buildMix rec {
      name = "websock";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0b1dvjbf5q8mlp0b464im633sib5byzdmxg50rxlbkc1ic88bxxr";
      };

      beamDeps = [];
    };

    websock_adapter = buildMix rec {
      name = "websock_adapter";
      version = "0.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hcf4ijbzpjp0nv0d7jwywjb562k4gsw5kpr8829spyypx21ablf";
      };

      beamDeps = [ plug plug_cowboy websock ];
    };

    yamerl = buildRebar3 rec {
      name = "yamerl";
      version = "0.10.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vjf9gnchvh4qfykrxf0jw0didvfrx54wdm26z41s1gicclxnsil";
      };

      beamDeps = [];
    };

    yaml_elixir = buildMix rec {
      name = "yaml_elixir";
      version = "2.9.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1z4dq1x60a1r0daa0vasqhzw2f8fxmqadl9y4nk9jpkgqpafgc0c";
      };

      beamDeps = [ yamerl ];
    };
  };
in self

