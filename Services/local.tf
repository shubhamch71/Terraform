# File to create a local file

resource "local_file" "myfile" {
    filename = "automate.txt"
    content = "best content for terraform"
    
  
}