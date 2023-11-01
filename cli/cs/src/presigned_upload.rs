extern crate serde_json;

use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize, Debug)]
pub struct PresignedUpload {
    fields: Fields,
    url: String,
    uploader: String,
}

#[derive(Deserialize, Serialize, Debug)]
pub struct Fields {
    key: String,
    policy: String,
    #[serde(rename = "x-goog-algorithm")]
    x_goog_algorithm: String,
    #[serde(rename = "x-goog-credential")]
    x_goog_credential: String,
    #[serde(rename = "x-goog-date")]
    x_goog_date: String,
    #[serde(rename = "x-goog-signature")]
    x_goog_signature: String,
}
