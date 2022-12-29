use crate::RequesterError;
use crate::Site;

pub fn parse(body: &str) -> Result<Vec<Site>, RequesterError> {
    let sites = serde_json::from_str(body);
    sites.map_err(|e| RequesterError::MalformedResponse(e.to_string()))
}

#[test]
fn invalid_json_causes_specific_error() {
    if let Err(RequesterError::MalformedResponse(e)) = parse("bad JSON") {
        assert!(
            e.to_string().starts_with("expected value at"),
            "{}",
            e.to_string()
        )
    } else {
        panic!("Should have produced a specific malformed JSON error")
    }
}
