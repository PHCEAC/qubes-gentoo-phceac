# Maintainer: Frédéric Pierret <frederic.pierret@qubes-os.org>

# Workaround for verifying git tags
# Feature request: https://bugs.gentoo.org/733430
qubes_verify_sources_git() {
    QUBES_OVERLAY_DIR="/var/db/repos/qubes-phceac"
    # Import Qubes developers keys
    gpg --verbose --import "${QUBES_OVERLAY_DIR}/keys/qubes-developers-keys.asc"  
    # Trust Qubes Master Signing Key
    echo '427F11FD0FAA4B080123F01CDDFA1A3E36879494:6:' | gpg --import-ownertrust --verbose
	echo "gpg import returned $?"

    VALID_TAG_FOUND=0
    for tag in $(git tag --points-at="$1"); do
        if git verify-tag --raw "$tag" 2>&1 | grep -q '^\[GNUPG:\] TRUST_\(FULLY\|ULTIMATE\)'; then
            VALID_TAG_FOUND=1
        fi
    done

    if [ "$VALID_TAG_FOUND" -eq 0 ]; then
        die 'Signature verification failed!'
    fi
}
