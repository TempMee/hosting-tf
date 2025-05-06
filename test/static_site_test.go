package test

import (
	"strings"
	"testing"
	"time"
	"net"
	"log"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestStaticWebsiteInfra(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1" // ACM for CloudFront must be in us-east-1
	name := "dev.tempdee.com"
	subDomain := "static"
	domainName := subDomain + "." + name

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"name": name,
			"subdomain": subDomain,
			"route53_zone_id": "Z05819972C5EK0GHLPRU1",
			"bucket_prefix": "static-site",
			"aws_region": awsRegion,

		},
		NoColor: true,

	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure with "terraform apply"
	terraform.InitAndApply(t, terraformOptions)


	// Verify outputs
	bucketID := terraform.Output(t, terraformOptions, "s3_bucket_id")
	cloudfrontDomain := terraform.Output(t, terraformOptions, "cloudfront_domain_name")

	// S3 Bucket check
	aws.AssertS3BucketExists(t, awsRegion, bucketID)

	// Verify that our Bucket has a policy attached
	aws.AssertS3BucketPolicyExists(t, awsRegion, bucketID)

	// Domain name check
	assert.Equal(t, domainName, terraform.Output(t, terraformOptions, "domain_name"))


	// ACM Certificate validation (only checking existence)
	certArn := terraform.Output(t, terraformOptions, "acm_certificate_arn")
	assert.True(t, strings.HasPrefix(certArn, "arn:aws:acm:"), "ACM ARN format is incorrect")

	// CloudFront Domain check
	assert.True(t, strings.HasSuffix(cloudfrontDomain, "cloudfront.net"))

	// Optional: test Route 53 resolution (might need to wait for propagation)
	time.Sleep(300 * time.Second) // give DNS time to propagate if needed
	publicIP, err := net.LookupIP(domainName)
	assert.NotEmpty(t, publicIP)
	if err != nil {
		log.Fatal(err)
	}

}
