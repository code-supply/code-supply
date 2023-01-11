mod parsing;
pub mod types;
pub use crate::types::RequesterError;
pub use crate::types::Site;
use url::Url;

pub struct Client<'a> {
    url: &'a url::Url,
    api_key: &'a str,
    reqwest_client: reqwest::blocking::Client,
}

impl<'a> Client<'a> {
    pub fn new(url: &'a Url, api_key: &'a str) -> Self {
        Client {
            url,
            api_key,
            reqwest_client: reqwest::blocking::Client::new(),
        }
    }

    pub fn list_sites(&self) -> Result<Vec<Site>, RequesterError> {
        let endpoint_url = self.url.join("sites")?;
        let req = self
            .reqwest_client
            .get(endpoint_url.as_str())
            .header("X-Affable-API-Key", self.api_key);
        let response = req.send()?;
        parsing::parse(&response.text()?)
    }
}
