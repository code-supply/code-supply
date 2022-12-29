use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Site {
    pub name: String,
}

pub struct Client<'a> {
    url: &'a url::Url,
}

impl<'a> Client<'a> {
    pub fn new(url: &'a Url) -> Self {
        Client { url }
    }

    pub fn list_sites(self: &Self) -> Result<String, RequesterError> {
        let endpoint_url = self.url.join("sites")?;
        let response = reqwest::blocking::get(endpoint_url.as_str())?;
        response.text().map_err(|_| RequesterError::IOError)
    }
}

use std::fmt::Debug;
use url::Url;

#[derive(Debug, PartialEq)]
pub enum RequesterError {
    ParseError,
    IOError,
}

impl From<url::ParseError> for RequesterError {
    fn from(_: url::ParseError) -> Self {
        RequesterError::ParseError
    }
}

impl From<reqwest::Error> for RequesterError {
    fn from(_: reqwest::Error) -> Self {
        RequesterError::IOError
    }
}
