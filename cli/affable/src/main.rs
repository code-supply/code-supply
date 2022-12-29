use affable::Client;
use affable::RequesterError;
use url::Url;

fn main() -> Result<(), RequesterError> {
    let url = &Url::parse("https://api.affable.app/")?;
    let client = Client::new(url);
    let response = client.list_sites()?;
    println!("Response: {:?}", response);
    Ok(())
}
