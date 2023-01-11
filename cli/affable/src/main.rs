use affable::Client;
use affable::RequesterError;
use url::Url;

fn main() -> Result<(), RequesterError> {
    let url = &Url::parse("https://api.affable.app/")?;
    let api_key = "abcdefg";
    let client = Client::new(url, api_key);
    let response = client.list_sites()?;
    println!("Response: {:?}", response);
    Ok(())
}
