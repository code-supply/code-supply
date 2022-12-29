use affable::Client;
use url::Url;

fn main() -> Result<(), affable::RequesterError> {
    let url = &Url::parse("https://api.affable.app/")?;
    let client = Client::new(url);
    let response = client.list_sites()?;
    println!("Response: {}", response);
    Ok(())
}
