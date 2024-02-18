using System;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Storage.v1.Data;
using Google.Cloud.Storage.V1;

namespace csharp
{
  class Program
  {
    static void Main(string[] args)
    {
        // https://cloud.google.com/docs/authentication/production
        var accessToken = args[0];
        Console.WriteLine(accessToken);
        
        var c = GoogleCredential.FromAccessToken(accessToken);

        Console.WriteLine("Hello World!");
        
        //   CreateBucket("gwc-wif", "helliofdnsaklfa");
        ListBucketContents(c, "xgwc-sandbox/");
    }

    public static Bucket
    CreateBucket(
      string projectId = "gwc-wif",
      string bucketName = "your-unique-bucket-name123"
    )
    {
      var storage = StorageClient.Create();
      var bucket = storage.CreateBucket(projectId, bucketName);
      Console.WriteLine($"Created {bucketName}.");
      return bucket;
    }

    public static void ListBucketContents(GoogleCredential credential, string bucketName) {
        var s = StorageClient.Create(credential);
        var x = s.ListObjects(bucketName);
        foreach(var a in x) {
            Console.WriteLine(a.Name);
        }
    }
  }
}
