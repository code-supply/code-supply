mod presigned_upload;
use presigned_upload::PresignedUpload;
use reqwest::header::AUTHORIZATION;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let api_token = "foobar";
    let client = reqwest::blocking::Client::new();
    let resp = client
        .get("http://hosting.code.test:4000/sites/1/presigned_upload")
        .header(AUTHORIZATION, format!("Bearer {}", api_token))
        .send();

    let presigned_upload: PresignedUpload = serde_json::from_str(&resp?.text().unwrap())?;
    println!("{:#?}", presigned_upload);
    Ok(())
}
