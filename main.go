package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/otiai10/gosseract/v2"
)

type PageData struct {
	ExtractedText string
	Error         string
	FileName      string
}

func main() {
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/upload", uploadHandler)
	fmt.Println("Server starting on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	tmpl := `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OCR Simple</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: Arial, sans-serif; padding: 15px; background: #f5f5f5; margin: 0; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 12px; border-radius: 4px; height: 88vh; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .side-by-side { display: flex; gap: 15px; height: 100%; }
        .left-panel, .right-panel { flex: 1; display: flex; flex-direction: column; }
        .image-preview { max-width: 100%; height: auto; border: 1px solid #ddd; border-radius: 3px; object-fit: contain; will-change: transform; }
        h1 { text-align: center; margin: 0 0 15px 0; font-size: 1.5em; }
        h3 { margin: 0 0 8px 0; font-size: 1.1em; }
        .upload-area { border: 2px dashed #ccc; padding: 25px; text-align: center; margin-bottom: 8px; border-radius: 4px; flex-grow: 1; display: flex; align-items: center; justify-content: center; flex-direction: column; transition: border-color 0.2s; }
        .upload-area.dragover { border-color: #007bff; background: #f8f9fa; }
        .btn { background: #007bff; color: white; border: none; padding: 6px 12px; border-radius: 3px; cursor: pointer; margin: 3px; font-size: 13px; transition: background-color 0.2s; }
        .btn:hover { background: #0056b3; }
        .extracted-text { background: white; padding: 8px; border: 1px solid #ddd; border-radius: 3px; font-family: 'Courier New', monospace; white-space: pre-wrap; flex-grow: 1; overflow-y: auto; min-height: 200px; font-size: 13px; line-height: 1.4; }
        input[type="file"] { display: none; }
        .copy-btn { background: #28a745; }
        .copy-btn:hover { background: #218838; }
        .result-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
        .processing { color: #666; font-style: italic; }
    </style>
</head>
<body>
    <div class="container">
        <h1>OCR Simple</h1>
        
        <div class="side-by-side">
            <div class="left-panel">
                <h3>Input Gambar:</h3>
                <div class="upload-area" id="uploadArea">
                    <div>Paste gambar (Ctrl+V), drag & drop, atau klik Browse</div>
                    <input type="file" id="fileInput" accept="image/*">
                    <button type="button" class="btn" onclick="document.getElementById('fileInput').click()">Browse</button>
                </div>
            </div>
            
            <div class="right-panel">
                <div class="result-header">
                    <h3>Hasil OCR:</h3>
                    <button class="btn copy-btn" id="copyBtn" onclick="copyText()" style="display: none;">Copy Text</button>
                </div>
                <div class="extracted-text" id="extractedText">Belum ada gambar yang diproses...</div>
            </div>
        </div>
    </div>

    <script>
        let currentFile = null;
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const extractedText = document.getElementById('extractedText');
        const copyBtn = document.getElementById('copyBtn');

        // Paste from clipboard
        document.addEventListener('paste', (e) => {
            const items = e.clipboardData.items;
            for (let item of items) {
                if (item.type.startsWith('image/')) {
                    const file = item.getAsFile();
                    handleFile(file);
                    break;
                }
            }
        });

        // File input change
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                handleFile(e.target.files[0]);
            }
        });

        // Drag and drop
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0 && files[0].type.startsWith('image/')) {
                handleFile(files[0]);
            }
        });

        function handleFile(file) {
            currentFile = file;
            
            // Optimized image preview with immediate OCR
            const reader = new FileReader();
            reader.onload = function(e) {
                uploadArea.innerHTML = '<img src="' + e.target.result + '" class="image-preview" alt="Preview">';
                extractText(); // Start OCR immediately
            };
            reader.readAsDataURL(file);
        }

        function extractText() {
            if (!currentFile) return;
            
            // Batch DOM updates for better performance
            extractedText.textContent = 'Processing...';
            extractedText.className = 'extracted-text processing';
            copyBtn.style.display = 'none';
            
            const formData = new FormData();
            formData.append('image', currentFile);
            
            fetch('/upload', {
                method: 'POST',
                body: formData
            })
            .then(r => r.json())
            .then(d => {
                // Single DOM update for better performance
                extractedText.className = 'extracted-text';
                const text = d.text || 'No text detected.';
                extractedText.textContent = d.error ? 'Error: ' + d.error : text;
                
                if (!d.error && d.text) {
                    copyBtn.style.display = 'inline-block';
                    navigator.clipboard.writeText(d.text).catch(() => {});
                }
            })
            .catch(e => {
                extractedText.className = 'extracted-text';
                extractedText.textContent = 'Error: ' + e.message;
            });
        }

        function copyText() {
            navigator.clipboard.writeText(extractedText.textContent);
            copyBtn.textContent = 'Copied!';
            setTimeout(() => copyBtn.textContent = 'Copy Text', 800);
        }
    </script>
</body>
</html>
`

	t, err := template.New("home").Parse(tmpl)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	data := PageData{}
	t.Execute(w, data)
}

func uploadHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	// Optimized form parsing with smaller memory footprint
	err := r.ParseMultipartForm(3 << 20) // 3 MB max for better performance
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(`{"error": "File too large or invalid form data"}`))
		return
	}

	// Get file from form
	file, header, err := r.FormFile("image")
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(`{"error": "No file uploaded or invalid file"}`))
		return
	}
	defer file.Close()

	// Fast file type validation
	if !isValidImageType(header.Filename) {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(`{"error": "Please upload a valid image file (PNG, JPG, JPEG, GIF, BMP)"}`))
		return
	}

	// Efficient file reading with pre-allocated buffer
	fileBytes, err := io.ReadAll(file)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error": "Failed to read uploaded file"}`))
		return
	}

	// Perform OCR processing
	extractedText, err := performOCRFromBytes(fileBytes)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(fmt.Sprintf(`{"error": "OCR failed: %v"}`, err)))
		return
	}

	// Optimized JSON response
	response := struct {
		Text     string `json:"text"`
		Filename string `json:"filename"`
	}{
		Text:     extractedText,
		Filename: header.Filename,
	}

	jsonData, err := json.Marshal(response)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(`{"error": "Failed to encode response"}`))
		return
	}
	w.Write(jsonData)
}

func isValidImageType(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))
	validExts := []string{".png", ".jpg", ".jpeg", ".gif", ".bmp"}
	for _, validExt := range validExts {
		if ext == validExt {
			return true
		}
	}
	return false
}

func performOCRFromBytes(imageBytes []byte) (string, error) {
	client := gosseract.NewClient()
	defer client.Close()

	// Ultra-fast OCR configuration
	client.SetLanguage("eng")
	client.SetPageSegMode(gosseract.PSM_SINGLE_BLOCK)
	client.SetVariable("tessedit_char_whitelist", "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,!?@#$%^&*()_+-=[]{}|;':,.<>?/~` ")
	client.SetVariable("tessedit_ocr_engine_mode", "1") // LSTM only
	client.SetVariable("tessedit_pageseg_mode", "6")     // Single uniform block
	client.SetVariable("classify_enable_learning", "0")  // Disable learning
	client.SetVariable("classify_enable_adaptive_matcher", "0")
	client.SetVariable("textord_really_old_xheight", "1")
	client.SetVariable("segment_penalty_dict_nonword", "1.25")
	client.SetVariable("language_model_penalty_non_freq_dict_word", "0.1")
	client.SetVariable("language_model_penalty_non_dict_word", "0.15")

	// Set image and extract text in one operation
	err := client.SetImageFromBytes(imageBytes)
	if err != nil {
		return "", fmt.Errorf("failed to set image: %v", err)
	}

	text, err := client.Text()
	if err != nil {
		return "", fmt.Errorf("failed to extract text: %v", err)
	}

	return strings.TrimSpace(text), nil
}

// Template functions dihapus untuk mengurangi overhead memori
