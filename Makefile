.PHONY: large-v3-turbo

large-v3-turbo:
	bash ./models/download-ggml-model.sh $@
	cmake -B build $(CMAKE_ARGS)
	cmake --build build --config Release
	@echo ""
	@echo "==============================================="
	@echo "Running $@ on all samples in ./samples ..."
	@echo "==============================================="
	@echo ""
	@for f in samples/*.{flac,mp3,ogg,wav}; do \
		echo "----------------------------------------------" ; \
		echo "[+] Running $@ on $$f ... (run 'ffplay $$f' to listen)" ; \
		echo "----------------------------------------------" ; \
		echo "" ; \
		./build/bin/whisper-cli -m models/ggml-$@.bin -f $$f ; \
		echo "" ; \
	done
	@mkdir -p workflow/whisper
	@mv models/ggml-$@.bin workflow/whisper/
	@mv build/bin/whisper-cli workflow/whisper/

	@if [ ! -d "$$HOME/Library/Services" ]; then \
		echo "Creating ~/Library/Services ..."; \
		mkdir -p "$$HOME/Library/Services"; \
	else \
		echo "~/Library/Services already exists. Skipping creation."; \
	fi
	@cp -R workflow/mp4-to-text.workflow "$$HOME/Library/Services/"
	@cp -R workflow/whisper "$$HOME/Library/Services/"
	@xcrun SetFile -a E "$$HOME/Library/Services/mp4-to-text.workflow" || true
	@echo "Installed:"
	@echo "  - $$HOME/Library/Services/mp4-to-text.workflow"
	@echo "  - $$HOME/Library/Services/whisper"
	