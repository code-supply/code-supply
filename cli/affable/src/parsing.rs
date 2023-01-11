use crate::RequesterError;
use crate::Site;

pub fn parse(body: &str) -> Result<Vec<Site>, RequesterError> {
    let sites = serde_json::from_str(body);
    sites.map_err(|e| RequesterError::MalformedResponse {
        body: body.to_string(),
        backtrace: e.to_string(),
    })
}

#[test]
fn invalid_json_causes_specific_error() {
    if let Err(RequesterError::MalformedResponse {
        body: _body,
        backtrace: e,
    }) = parse("bad JSON")
    {
        assert!(e.starts_with("expected value at"), "{}", e)
    } else {
        panic!("Should have produced a specific malformed JSON error")
    }
}
