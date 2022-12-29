use affable::{Client, Site};
use pact_consumer::prelude::*;

#[test]
fn can_list_sites() {
    let site = Site {
        name: "My Site".to_owned(),
    };
    let serialised_site = &serde_json::to_string(&site).unwrap();
    let affable_service = PactBuilder::new("Consumer", "Affable Service")
        .interaction("a list sites request", "", |mut i| {
            i.given("there is a site");
            i.request.path("/sites");
            i.response
                .content_type("application/json")
                .body(serialised_site);
            i
        })
        .start_mock_server(None);

    let url = &affable_service.url();
    let client = Client::new(url);
    let response = client.list_sites();
    assert_eq!(response, Ok(serialised_site.to_string()));
}
