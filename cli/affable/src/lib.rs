mod parsing;
pub mod types;
pub use crate::types::RequesterError;
pub use crate::types::Site;
use url::Url;

pub struct Client<'a> {
    url: &'a url::Url,
}

impl<'a> Client<'a> {
    pub fn new(url: &'a Url) -> Self {
        Client { url }
    }

    pub fn list_sites(self: &Self) -> Result<Vec<Site>, RequesterError> {
        let endpoint_url = self.url.join("sites")?;
        let response = reqwest::blocking::get(endpoint_url.as_str())?;
        parsing::parse(&response.text()?)
    }
}
