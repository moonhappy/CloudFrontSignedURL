Pod::Spec.new do |s|

  s.name             = 'CloudFrontSignedURL'
  s.version          = '0.5.0'
  s.summary          = 'Helper to generate AWS CloudFront Signed URL.'

  s.description      = <<-DESC
AWS CloudFront is a Content Delivery Network (CDN) that allows low-latency, globally distributed, content delivery.
CloudFrontSignedURL helps generate Signed URLs where certain content is to require access privilege.
See [CloudFront](https://aws.amazon.com/cloudfront/) and [Signed URL](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-urls.html for details.
                       DESC

  s.homepage         = 'https://github.com/moonhappy/CloudFrontSignedURL'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'github.com/moonhappy'
  s.source           = { :git => 'https://github.com/moonhappy/CloudFrontSignedURL.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'

  s.source_files = 'CloudFrontSignedURL/Classes/**/*'
  s.frameworks = 'Security'

end
