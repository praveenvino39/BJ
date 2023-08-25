class SuperUri {
  final String urlString;
  SuperUri({required this.urlString});

  getUri(){
    String resultUri = "";
    if(urlString.contains("https")){
      resultUri += "https";
    }else if(urlString.contains("http")){
      resultUri += "http";
    }
    resultUri += urlString;
  }
}