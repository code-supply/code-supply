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
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19bp6xh052ql3ha0v3r8999cvja5d2p6cph02mxphfaj4jsbyc53";
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
      version = "1.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1mv9lyw6hgjn6hlnzfbs0x2dchvwlmj8bg0a8l7iq38z7pvgqfb8";
      };

      beamDeps = [ bunt file_system jason ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.5.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18jsnmabdjwj3i7ml43ljzrzzvfy1a3bnbaqywgsv7nndji5nbf9";
      };

      beamDeps = [ telemetry ];
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
      version = "1.3.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0vv90jip2w362n3l7dkhqfdwlz97nwji535kn3fbk3dassya9ch0";
      };

      beamDeps = [ erlex ];
    };

    earmark = buildMix rec {
      name = "earmark";
      version = "1.4.39";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0h547ri1nbxyaisyx7jddg3wib7fpm3q4v914szwvv6bqf79sv0m";
      };

      beamDeps = [ earmark_parser ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.33";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "13qvlqnii8g6bcz6cl330vjwaan7jy30g1app3yvjncvf8rnhlid";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.9.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "111cnw9p1zhirrd10nic6fcl8pzyfzw4x8g4cjvsfy3gp83bq5yz";
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
      version = "0.7.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0v3y9i3bif14486dliwn9arwd0pcp4nv24gjwnxm5b8gjpzrzhav";
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
      version = "0.7.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0g7i36fsnry20w15lq5jc6bval3pwv73ymqnvkj8wdxif3giqrk6";
      };

      beamDeps = [ castore ];
    };

    expo = buildMix rec {
      name = "expo";
      version = "0.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0iyfl4vppfhmimfqaracjza9a6y8rgia03sm28y5934cg5xbmxrg";
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
      version = "0.16.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1iayffbjzb1rcy1p0wibzv6j5n7dc16ha5lhcbn5z7ji9m61fq7n";
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
      version = "0.22.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1gb49f75apkgfa5ddg02x08w1i3qm31jifzicrl4m58kfx226pwk";
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
      version = "0.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0yfan7iykib3x7lxirymxd87vli369g4fqpr27kc0h28w3kxrxxf";
      };

      beamDeps = [ mime poison tesla ];
    };

    goth = buildMix rec {
      name = "goth";
      version = "1.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "00gr4shkl38afkzb8cyy72r5bgrc5w4lglvlch6rx384g4c9h1n9";
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
      version = "0.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "06yrgpird9kwqchs8vflza4w8y41hxbljf8i1kwl6dgjhx2qq8jy";
      };

      beamDeps = [ mox ordinal telemetry ];
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
      version = "1.8.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "08crb48yz7r7w00pzw9gfk862g99z2ma2x6awab0rqvjd7951crb";
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
      version = "1.4.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "18d70i31bz11nr6vgsjn5prvhkvwqbyf3xq22ck5cnsnzp6ixc7v";
      };

      beamDeps = [ decimal ];
    };

    jose = buildMix rec {
      name = "jose";
      version = "1.11.6";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0f4pzx8xdzjkkfjkl442w6lhajgfzsnp3dxcxrh1x72ga1swnxb2";
      };

      beamDeps = [];
    };

    k8s = buildMix rec {
      name = "k8s";
      version = "1.2.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0wh67cy1a89zppvy51ar269laf606vvy8v02jib9n263h86q6bpi";
      };

      beamDeps = [ castore httpoison jason telemetry websockex yaml_elixir ];
    };

    libcluster = buildMix rec {
      name = "libcluster";
      version = "3.3.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1rgyppih5lv2rkn0wx86a4a7p2dlpz1v7nhprmxc10xvl1sj42kw";
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
      version = "1.6.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "19qrpnmaf3w8bblvkv6z5g82hzd10rhc7bqxvqyi88c37xhsi89i";
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
      version = "1.5.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "07jvgmggmv6bxhkmrskdjz1xvv0a1l53fby7sammcfbwdbky2qsa";
      };

      beamDeps = [ castore hpax ];
    };

    mix_test_watch = buildMix rec {
      name = "mix_test_watch";
      version = "1.1.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1hrfh7hg3iwmvzwwyshdddgjxwc2ci898lyak7c0zdybfv2b3djj";
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
      version = "1.0.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1f7ih1rnkvph0daf4lsv4rrp6dpccksjd7rh5bhnq0r143dsh4px";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "1.0.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0ymn22kj8jkyx1xjh2ldz65s4lhr3f70g1v04n11hd9d5n43pgl0";
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
      version = "1.7.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "119h8lcvarlm7xrlrb301wgrd3plwwmbvl3f3dckfpjy75ff2rl9";
      };

      beamDeps = [ castore jason phoenix_pubsub phoenix_template phoenix_view plug plug_cowboy plug_crypto telemetry websock_adapter ];
    };

    phoenix_ecto = buildMix rec {
      name = "phoenix_ecto";
      version = "4.4.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0pcgrvj5lqjmsngrhl77kv0l8ik8gg7pw19v4xlhpm818vfjw93h";
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
      version = "0.19.5";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1lx9gi70a3cabjnjhslqbs8ysnpjz5yj324vjkxxg6zv7kfs1smj";
      };

      beamDeps = [ jason phoenix phoenix_html phoenix_template phoenix_view telemetry ];
    };

    phoenix_pubsub = buildMix rec {
      name = "phoenix_pubsub";
      version = "2.1.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "00p5dvizhawhqbia2cakdn4whaxsm2adq3lzfn3b137xvk0np85v";
      };

      beamDeps = [];
    };

    phoenix_template = buildMix rec {
      name = "phoenix_template";
      version = "1.0.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0b4fbp9dhfii6njksm35z8xf4bp8lw5hr7bv0p6g6lj1i9cbdx0n";
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
      version = "1.1.7";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1y37pj5q6gk1vrnwg1vraws9yihrv9g4133w2qq1sh1piw71jk7y";
      };

      beamDeps = [];
    };

    swoosh = buildMix rec {
      name = "swoosh";
      version = "1.11.4";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "03rxj2jdrjg6pab05iz8myr0j9fi3d1v7z2bc3hnli9a08a0jffk";
      };

      beamDeps = [ cowboy finch hackney jason mime plug_cowboy telemetry ];
    };

    tailwind = buildMix rec {
      name = "tailwind";
      version = "0.2.1";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0xx2r741jzh669229nni7h4mmsz18hbj5d6iivjp6py90xhkz8g8";
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
      version = "1.7.0";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "04y31nq54j1wnzpi37779bzzq0sjwsh53ikvnh4n40nvpwgg0r1f";
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
      version = "0.5.2";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "01gzcvz86x4hxk5d50qz38nkmi1fakyn5yw0m7gi6s6a5zi5spwj";
      };

      beamDeps = [];
    };

    websock_adapter = buildMix rec {
      name = "websock_adapter";
      version = "0.5.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "0g8djd6l1yq8s84y4r3938dczvjs6jgxjbdm0ah6wszqq4abirfb";
      };

      beamDeps = [ plug plug_cowboy websock ];
    };

    websockex = buildMix rec {
      name = "websockex";
      version = "0.4.3";

      src = fetchHex {
        pkg = "${name}";
        version = "${version}";
        sha256 = "1r2kmi2pcmdzvgbd08ci9avy0g5p2lhx80jn736a98w55c3ygwlm";
      };

      beamDeps = [];
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

