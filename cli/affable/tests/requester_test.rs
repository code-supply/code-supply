use affable::*;
use pact_consumer::prelude::*;

#[test]
fn can_list_sites() {
    let stubbed_sites = vec![Site {
        name: String::from("My Site"),
    }];
    let serialised_sites = &serde_json::to_string(&stubbed_sites).unwrap();
    let affable_service = PactBuilder::new("Consumer", "Affable Service")
        .interaction("a list sites request", "", |mut i| {
            i.given("user Freda exists");
            i.given("site exists for user Freda");
            i.request.path("/sites").header_from_provider_state(
                "X-Affable-API-Key",
                "user Freda exists",
                "my-api-key",
            );
            i.response
                .content_type("application/json")
                .body(serialised_sites);
            i
        })
        .start_mock_server(None);
    let url = &affable_service.url();
    let client = Client::new(url, "my-api-key");

    let response = client.list_sites();

    assert_eq!(Ok(stubbed_sites), response);
}
