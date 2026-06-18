# Image Designer Utility: image-designer

## Design Requirements and User Preferences

### Itinerary Poster Design Requirements

#### 1. Dimensions and Format
- **Size**: Must use full background image dimensions: 1080x1920 pixels
- **Aspect Ratio**: Mobile vertical screen (1080x1920), NOT A4 paper size (792x1131)
- **Format**: PNG with transparency support
- **Background**: Full background images should not be cropped
- **User preference**: Even if source material is A4 format, output must adapt to mobile vertical screen

#### 2. Visual Elements
- **Bell Icon**: Must be correctly displayed and visible
- **Typography**: 
  - Main titles should have design sense
  - Prefer Chinese calligraphy fonts: 华文行楷 (STXingkai), Xingkai SC
  - Boxes and text should be appropriately enlarged for better visual coordination
  - **User preference**: "主标题要有设计感，优先使用华文行楷等书法字体。方框和文字要适当调大以提升整体视觉协调性"
- **Layout**: Responsive design that adapts to mobile viewing

#### 3. Technical Implementation
- **Resource Handling**: Use Base64 embedded resources to avoid file access restrictions
- **Font Loading**: Ensure Chinese fonts are properly loaded and displayed
- **Image Optimization**: Optimize for mobile delivery while maintaining quality

#### 4. User Feedback Integration
- **Single Push**: Only push one PNG file, not multiple
- **Clean Delivery**: Use `MEDIA:` syntax without technical file paths
- **Test Mode Support**: Allow temporary modifications for testing purposes
- **User feedback**: "图片很有意思" indicates satisfaction with visual design
- **Push optimization**: Based on user feedback "你又同时推送两张海报到群里，其实一张就够了"

## Original Skill Content

This file contains the detailed implementation of the image design utility that was previously `image-designer`.

## Overview

**image-designer** is a utility skill for generating images from HTML designs. It's primarily used by `postsign-agent` to create payment posters, but can be used for any HTML-to-image conversion needs within the signing workflow system.

## Core Functionality

### 1. HTML Page Design
- Create responsive HTML designs
- Support for CSS styling and JavaScript
- Template-based design system

### 2. Browser Screenshot Capture
- Headless browser automation
- Custom viewport sizing
- Quality and format control

### 3. PNG Output Generation
- High-quality PNG output
- Configurable dimensions and DPI
- Optimized file size

### 4. Template Management
- Reusable design templates
- Variable substitution
- Style customization

## Workflow Steps

### Step 1: Design HTML Page
```html
<!-- Example payment poster HTML -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Poster</title>
    <style>
        .poster {
            width: 800px;
            height: 1200px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            font-family: 'Helvetica Neue', Arial, sans-serif;
            padding: 40px;
            box-sizing: border-box;
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
        }
        .title {
            font-size: 48px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .subtitle {
            font-size: 24px;
            opacity: 0.9;
        }
        .content {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
        }
        .amount {
            font-size: 64px;
            font-weight: bold;
            color: #ffd700;
            text-align: center;
            margin: 20px 0;
        }
        .deadline {
            font-size: 32px;
            text-align: center;
            color: #ff6b6b;
            margin-bottom: 30px;
        }
        .instructions {
            font-size: 18px;
            line-height: 1.6;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            font-size: 16px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="poster">
        <div class="header">
            <div class="title">保单缴费通知</div>
            <div class="subtitle">{{client_name}} | {{policy_number}}</div>
        </div>
        
        <div class="content">
            <div class="amount">{{payment_amount}}</div>
            <div class="deadline">缴费截止: {{payment_deadline}}</div>
            
            <div class="instructions">
                <h3>缴费方式:</h3>
                <ul>
                    <li>银行转账: {{bank_account}}</li>
                    <li>在线支付: {{payment_link}}</li>
                    <li>支票支付: {{mailing_address}}</li>
                </ul>
                
                <h3>重要提示:</h3>
                <p>请在缴费时备注: {{reference_number}}</p>
                <p>缴费后请保留付款凭证</p>
                <p>如有疑问请联系: {{contact_info}}</p>
            </div>
        </div>
        
        <div class="footer">
            {{company_name}} | {{current_date}}
        </div>
    </div>
</body>
</html>
```

### Step 2: Capture Browser Screenshot
```bash
# Command-line interface
image-designer \
    --input payment-poster.html \
    --output payment-poster.png \
    --width 800 \
    --height 1200 \
    --format png \
    --quality 90 \
    --wait 2000 \
    --full-page false
```

### Step 3: Generate PNG Output
```python
# Python API example
from image_designer import ImageDesigner

designer = ImageDesigner()
result = designer.generate(
    html_file="payment-poster.html",
    output_file="payment-poster.png",
    variables={
        "client_name": "杨洪伟",
        "payment_amount": "USD 10,000",
        "payment_deadline": "2026-06-20"
    },
    options={
        "width": 800,
        "height": 1200,
        "format": "png",
        "quality": 90
    }
)

if result.success:
    print(f"Image generated: {result.output_path}")
else:
    print(f"Error: {result.error}")
```

## Configuration Options

### Output Formats
```yaml
formats:
  png:
    default_quality: 90
    supports_transparency: true
    max_dimensions: 4096x4096
    
  jpg:
    default_quality: 85
    supports_transparency: false
    max_dimensions: 8192x8192
    
  webp:
    default_quality: 80
    supports_transparency: true
    max_dimensions: 16384x16384
```

### Browser Settings
```yaml
browser:
  headless: true
  user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
  viewport:
    default_width: 1920
    default_height: 1080
  timeout: 30000  # milliseconds
  retry_attempts: 3
```

### Template System
```yaml
templates:
  payment-poster:
    path: "templates/payment-poster.html"
    variables:
      required: ["client_name", "payment_amount", "payment_deadline"]
      optional: ["policy_number", "contact_info", "reference_number"]
    styles:
      default: "templates/styles/default.css"
      dark: "templates/styles/dark.css"
      minimal: "templates/styles/minimal.css"
```

## Template Management

### Built-in Templates

1. **Payment Poster Template**
   - Purpose: Payment information visualization
   - Size: 800x1200 pixels
   - Features: Amount highlighting, deadline emphasis, payment methods

2. **Receipt Template**
   - Purpose: Payment confirmation receipt
   - Size: 600x800 pixels
   - Features: Transaction details, verification QR code, company branding

3. **Reminder Template**
   - Purpose: Payment reminder notice
   - Size: 600x400 pixels
   - Features: Urgent styling, clear call-to-action, contact information

### Custom Template Creation
```html
<!-- Creating a custom template -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{template_name}}</title>
    <style>
        /* Template-specific styles */
        {{> base_styles}}
        {{> template_styles}}
    </style>
</head>
<body>
    <div class="template-container">
        <!-- Template content with variables -->
        <h1>{{title}}</h1>
        <div class="content">
            {{content}}
        </div>
        <div class="footer">
            {{footer_text}}
        </div>
    </div>
    
    <!-- Optional JavaScript -->
    <script>
        {{> template_scripts}}
    </script>
</body>
</html>
```

## Integration with Post-Signing Agent

### Payment Poster Generation Workflow
```python
def generate_payment_poster_for_client(client_data, payment_info):
    # Prepare template variables
    variables = {
        "client_name": client_data.name,
        "policy_number": payment_info.policy_number,
        "payment_amount": payment_info.amount,
        "payment_deadline": payment_info.deadline,
        "bank_account": payment_info.bank_account,
        "payment_link": payment_info.online_payment_link,
        "mailing_address": payment_info.mailing_address,
        "reference_number": payment_info.reference,
        "contact_info": payment_info.contact,
        "company_name": "保险公司",
        "current_date": datetime.now().strftime("%Y-%m-%d")
    }
    
    # Generate HTML with variables
    html_content = render_template("payment-poster.html", variables)
    
    # Generate image
    image_path = generate_image_from_html(
        html_content=html_content,
        output_path=f"payment-posters/{client_data.id}.png",
        width=800,
        height=1200
    )
    
    return image_path
```

## Error Handling

### Common Errors

1. **HTML parsing errors**: Check HTML syntax, validate with W3C validator
2. **Browser launch failures**: Verify browser installation, check permissions
3. **Screenshot failures**: Adjust wait time, check viewport settings
4. **File system errors**: Check disk space, verify write permissions

### Recovery Procedures

```python
def safe_image_generation(html_content, output_path, max_retries=3):
    for attempt in range(max_retries):
        try:
            result = generate_image(html_content, output_path)
            if result.success:
                return result
        except BrowserError as e:
            if attempt < max_retries - 1:
                # Restart browser and retry
                restart_browser()
                continue
            else:
                raise
        except FileSystemError as e:
            # Check disk space and permissions
            if not has_disk_space():
                clear_temp_files()
            if not has_write_permission(output_path):
                change_output_path()
            continue
    
    # Last resort: generate simple fallback
    return generate_fallback_image(output_path)
```

## Performance Optimization

### Caching Strategy
```python
class ImageCache:
    def __init__(self, max_size=100):
        self.cache = {}
        self.max_size = max_size
    
    def get(self, html_hash, options):
        key = f"{html_hash}_{options_hash}"
        if key in self.cache:
            return self.cache[key]
        return None
    
    def set(self, html_hash, options, image_path):
        if len(self.cache) >= self.max_size:
            # Remove oldest entry
            oldest_key = next(iter(self.cache))
            del self.cache[oldest_key]
        
        key = f"{html_hash}_{options_hash}"
        self.cache[key] = image_path
```

### Batch Processing
For multiple images:
- Reuse browser instance
- Parallel processing where possible
- Shared template compilation

## Quality Control

### Image Quality Settings
```yaml
quality_presets:
  low:
    format: "jpg"
    quality: 60
    compression: "high"
    
  medium:
    format: "png"
    quality: 80
    compression: "medium"
    
  high:
    format: "png"
    quality: 95
    compression: "low"
    
  ultra:
    format: "webp"
    quality: 100
    compression: "none"
```

### Validation Checks
1. **Dimension validation**: Verify output matches requested dimensions
2. **File size validation**: Check if file size is within expected range
3. **Color validation**: Verify color profile and transparency
4. **Content validation**: OCR check for expected text content

## Testing

### Unit Tests
```python
def test_html_rendering():
    html = "<h1>Test</h1>"
    image_path = generate_image(html, "test.png")
    assert os.path.exists(image_path)
    assert get_image_dimensions(image_path) == (800, 600)
    
def test_variable_substitution():
    template = "<h1>{{title}}</h1>"
    html = render_template(template, {"title": "Test Title"})
    assert "Test Title" in html
    assert "{{title}}" not in html
```

### Integration Tests
```bash
# Test full image generation workflow
./test-image-generation.sh \
    --template payment-poster \
    --variables client_name=测试金额=USD10,000截止=2026-06-20 \
    --output test-poster.png \
    --validate
```

## Monitoring

### Key Metrics
- Images generated per hour
- Average generation time
- Success/failure rate
- Cache hit rate
- Browser instance health

### Logging
```bash
# Sample log entries
[INFO] Template loaded: payment-poster.html
[INFO] Variables substituted: 5 variables replaced
[INFO] Browser launched: headless Chrome 120.0.6099.130
[INFO] Screenshot captured: 800x1200 pixels
[INFO] Image saved: test-poster.png (245KB)
[INFO] Cache updated: key=abc123, hit=false
```

## Security Considerations

### HTML Security
- Sanitize user-provided HTML
- Restrict JavaScript execution in templates
- Validate CSS for security issues
- Sandbox browser execution

### File System Security
- Restrict output directory access
- Validate file paths to prevent directory traversal
- Set appropriate file permissions
- Clean up temporary files

## Migration Notes

This content was migrated from the standalone `image-designer` skill as part of the umbrella consolidation. All functionality remains intact, now organized under the comprehensive `signing-workflow-system` umbrella.