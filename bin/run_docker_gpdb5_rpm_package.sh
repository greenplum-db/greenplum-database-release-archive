#!/bin/bash

set -eu

main() {
	local platform
	local docker_image_tag
	case "${CENTOS_VERSION}" in
	[6-7])
		platform="rhel${CENTOS_VERSION}"
		docker_image_tag="${CENTOS_VERSION}-gcc6.2-llvm3.7"
		;;
	*)
		printf "Unexpected value for \$CENTOS_VERSION='%s'\n" "${CENTOS_VERSION}"
		exit 1
		;;
	esac

	local bin_gpdb_path
	bin_gpdb_path="$(readlink -f "${BIN_GPDB_TARGZ}")"

	test -f "${bin_gpdb_path}" || {
		printf "File in \$BIN_GPDB_TARGZ does not exist\n"
		exit 1
	}

	docker run -it \
		-v "${PWD}":/tmp/greenplum-database-release \
		-v "${bin_gpdb_path}":/tmp/greenplum-database-release/bin_gpdb/bin_gpdb.tar.gz \
		-w /tmp/greenplum-database-release \
		-e GPDB_VERSION="${GPDB_VERSION}" \
		-e PLATFORM="${platform}" \
		pivotaldata/centos-gpdb-dev:"${docker_image_tag}" \
		/tmp/greenplum-database-release/bin/create_gpdb5_rpm_package.sh
}

main "${@}"
