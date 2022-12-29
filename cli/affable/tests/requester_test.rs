use affable::Client;
use affable::Site;
use pact_consumer::prelude::*;

#[test]
fn can_list_sites() {
    let stubbed_sites = vec![Site {
        name: "My Site".to_owned(),
    }];
    let serialised_sites = &serde_json::to_string(&stubbed_sites).unwrap();
    let affable_service = PactBuilder::new("Consumer", "Affable Service")
        .interaction("a list sites request", "", |mut i| {
            i.given("there is a site");
            i.request.path("/sites");
            i.response
                .content_type("application/json")
                .body(serialised_sites);
            i
        })
        .start_mock_server(None);
    let url = &affable_service.url();
    let client = Client::new(url);

    let response_sites = client.list_sites();

    assert_eq!(response_sites, Ok(stubbed_sites));
}
