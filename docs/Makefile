.PHONY: default clean hugo hugo-build

default: hugo

clean:
	rm -rf public/

hugo-build: clean hugo-themes
	hugo --enableGitInfo --source .

hugo:
	# hugo server --disableFastRender --enableGitInfo --watch --source .
	hugo server -D
	# hugo server -D

hugo-themes:
	rm -rf themes
	mkdir themes
	git clone --depth=1 https://github.com/llc1123/hugo-theme-techdoc.git themes/hugo-theme-techdoc
	rm -rf themes/hugo-theme-techdoc/.git
	git clone --depth=1 https://github.com/alex-shpak/hugo-book themes/hugo-book
	rm -rf themes/hugo-book/.git
