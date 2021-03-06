# List of Ubuntu releases to get
version_codename_list=trusty xenial yakkety zesty
# List of Ubuntu architectures to get
arch_list=i386 amd64

version_id_list=$(foreach version_codename,$(version_codename_list),$(value version_id_for_codename_$(version_codename)))

i386_img_list=$(foreach version_id,$(version_id_list),ubuntu-$(version_id)-32.img)
amd64_img_list=$(foreach version_id,$(version_id_list),ubuntu-$(version_id)-64.img)

# version_codename to version_id mapping
version_id_for_codename_trusty=14.04
version_id_for_codename_xenial=16.04
version_id_for_codename_yakkety=16.10
version_id_for_codename_zesty=17.04

target_list=$(foreach arch,$(arch_list),$($(arch)_img_list))
.PHONY: all
all: $(target_list)

.PHONY: clean
clean:
	rm -f $(target_list) adt-*.img

# call with version_codename (e.g. trusty)
define release_rule
adt-$(1)-amd64-cloud.img:
	adt-buildvm-ubuntu-cloud --verbose $(if $(APT_PROXY), -p $(APT_PROXY)) -r $(1) -a amd64
adt-$(1)-i386-cloud.img:
	adt-buildvm-ubuntu-cloud --verbose $(if $(APT_PROXY), -p $(APT_PROXY)) -r $(1) -a i386
ubuntu-$$(version_id_for_codename_$(1))-64.img: adt-$(1)-amd64-cloud.img
	ln -s $$^ $$@
ubuntu-$$(version_id_for_codename_$(1))-32.img: adt-$(1)-i386-cloud.img
	ln -s $$^ $$@
endef

$(foreach version_codename,$(version_codename_list),$(eval $(call release_rule,$(version_codename))))
