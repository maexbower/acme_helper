#!/bin/bash
DOMAINLIST="/home/acmeuser/.acme.sh/domains.conf"
SERVICESLIST="/home/acmeuser/.acme.sh/services.conf"
ACMEPATH="/home/acmeuser/.acme.sh/acme.sh"
RSA_KEYLENGTH="4096"
RSA_CERT_DST="/etc/letsencrypt/rsa-certs/cert.pem"
RSA_KEY_DST="/etc/letsencrypt/rsa-certs/privkey.pem"
RSA_CHAIN_DST="/etc/letsencrypt/rsa-certs/chain.pem"
RSA_FULLCHAIN_DST="/etc/letsencrypt/rsa-certs/fullchain.pem"
ECC_CERT_DST="/etc/letsencrypt/ecc-certs/cert.pem"
ECC_KEY_DST="/etc/letsencrypt/ecc-certs/privkey.pem"
ECC_CHAIN_DST="/etc/letsencrypt/ecc-certs/chain.pem"
ECC_FULLCHAIN_DST="/etc/letsencrypt/ecc-certs/fullchain.pem"
ECC_KEYLENGTH="ec-384"
WEBROOT="/var/www/letsencrypt"


function issuecert () {
        KEYLENGTH=$1
        CERT_DST=$2
        KEY_DST=$3
        CHAIN_DST=$4
        FULLCHAIN_DST=$5
        ACME_CMD_2=""
        ACME_CMD_1="${ACMEPATH} --issue "
        ACME_CMD_3=" --keylength ${KEYLENGTH} -w ${WEBROOT} --key-file ${KEY_DST} --ca-file ${CHAIN_DST} --cert-file ${CERT_DST} --fullchain-file ${FULLCHAIN_DST}"
        ACME_CMD_4=""
        if [ -e "${DOMAINLIST}" ]
        then
                while read line; do
                        printf "found domain %s\n" "${line}"
                        ACME_CMD_2="${ACME_CMD_2} -d ${line}"
                done <${DOMAINLIST}
                if [ "${ACME_CMD_2}" = "" ]
                then
                        echo "File is empty. Cannot run without domains."
                        exit 1
                fi
        else
                echo "File not exists. Cannot run without domains"
                exit 1
        fi
        if [ -e "${SERVICESLIST}" ]
        then
                while read line; do
                        printf "found service to restart %s\n" "${line}"
                        ACME_CMD_4="${ACME_CMD_4} ${line}"
                done <${SERVICESLIST}
                if [ "${ACME_CMD_4}" != "" ]
                then
                        ACME_CMD_4=" --reloadcmd \"sudo /bin/systemctl reload-or-restart ${ACME_CMD_4}\""
                fi
        else
                echo "running without reload action"
        fi
        echo "Running ISSUE: ${ACME_CMD_1}${ACME_CMD_2}${ACME_CMD_3}${ACME_CMD_4}"
        eval "${ACME_CMD_1}${ACME_CMD_2}${ACME_CMD_3}${ACME_CMD_4}"
}



echo "Update acme.sh procedure"

echo "Issue RSA Cert with the following parameters:"
issuecert "${RSA_KEYLENGTH}" "${RSA_CERT_DST}" "${RSA_KEY_DST}" "${RSA_CHAIN_DST}" "${RSA_FULLCHAIN_DST}"

echo "Issue ECC Cert with the following parameters:"
issuecert "${ECC_KEYLENGTH}" "${ECC_CERT_DST}" "${ECC_KEY_DST}" "${ECC_CHAIN_DST}" "${ECC_FULLCHAIN_DST}"
