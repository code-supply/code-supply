use serde::{Deserialize, Serialize};

#[derive(Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Site {
    pub name: String,
}

#[derive(Debug, PartialEq, Eq)]
pub enum RequesterError {
    URLParseError(String),
    IOError(String),
    MalformedResponse(String),
}

impl From<url::ParseError> for RequesterError {
    fn from(e: url::ParseError) -> Self {
        RequesterError::URLParseError(e.to_string())
    }
}

impl From<reqwest::Error> for RequesterError {
    fn from(e: reqwest::Error) -> Self {
        RequesterError::IOError(e.to_string())
    }
}
