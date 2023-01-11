use affable::Client;
use affable::RequesterError;
use clap::Parser;
use clap::ValueEnum;
use url::Url;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[arg(value_enum)]
    verb: Verb,
    #[arg(value_enum)]
    resource: Resource,
    #[arg(env, long)]
    api_key: String,
    #[arg(env, long, default_value = "https://api.affable.app/")]
    api_url: String,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum)]
enum Verb {
    List,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum)]
enum Resource {
    Sites,
}

fn main() -> Result<(), RequesterError> {
    let cli = Cli::parse();

    match cli.verb {
        Verb::List => {
            let url = &Url::parse("https://api.affable.app/")?;
            let client = Client::new(url, &cli.api_key);
            let response = client.list_sites()?;
            println!("Response: {:?}", response);
            Ok(())
        }
    }
}
