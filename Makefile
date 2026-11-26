JANET_REPO ?= /home/felix/misc/janet/janet-lang
JANETS_DIR ?= ./janets
JANET ?= janet
VERSIONS ?= v1.10.1 v1.11.3 v1.12.2 v1.14.2 v1.15.5 v1.16.1 v1.17.2 v1.18.1 v1.19.2 v1.20.0 v1.21.2 v1.22.0 v1.23.0 v1.24.1 v1.25.1 v1.26.0 v1.27.0 v1.28.0 v1.29.1 v1.30.0 v1.31.0 v1.32.1 v1.33.0 v1.34.0 v1.35.2 v1.36.0 v1.37.1 v1.38.0 v1.39.1 v1.40.1 v1.41.0 v1.41.1 v1.41.2 v1.42.1 v1.43.1



TARGETS := $(patsubst %,$(JANETS_DIR)/janet-%,$(VERSIONS))

.PHONY: all bench report clean

all: $(TARGETS)

$(JANETS_DIR)/janet-%:
	@mkdir -p $(JANETS_DIR)
	@rev=$$(jj -R $(JANET_REPO) tag list | awk -F': ' -v tag="$*" '$$1 == tag { split($$2, a, " "); print a[1]; exit }'); \
	if [ -z "$$rev" ]; then \
		echo "Error: tag '$*' not found in $(JANET_REPO)" >&2; \
		exit 1; \
	fi; \
	echo "Building $* (commit $$rev)..."; \
	jj -R $(JANET_REPO) new "$$rev" && \
	$(MAKE) -C $(JANET_REPO) clean && \
	$(MAKE) -j8 -C $(JANET_REPO) && \
	cp $(JANET_REPO)/build/janet $@

bench:
	@for bin in $(JANETS_DIR)/janet-*; do \
		if [ -x "$$bin" ]; then \
			echo "Running benchmarks for $$bin..."; \
			$(JANET) run.janet "$$bin" || exit 1; \
		fi; \
	done

report:
	$(JANET) report.janet > report.dat
	$(JANET) build_dashboard.janet

clean:
	rm -f $(TARGETS)
