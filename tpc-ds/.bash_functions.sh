#!/bin/sh
#
# Generate tpc-ds data on the VM
# You will need to have the tpcds dsdgen program built in the current directory
#
# Usage:
# To be run on generation VM
# Input:
# "${1}" : size of the batch in GB
# "${2}" : number of parallel data generation streams
# Ouput:
# files will be in "${TPCDS_DATA_DIR}"/
#
tpcds_gen() {
SCALE="${1}"
PARALLEL="${2}"
CHILD=1
TPCDS_DATA_DIR=~/"${TPCDS_DIR}"/data/"${SCALE}"gb/
sudo mkdir -p "${TPCDS_DATA_DIR}"
sudo rm -rf "${TPCDS_DATA_DIR}"*
sudo chmod a+rwx "${TPCDS_DATA_DIR}"
echo -e "\nCreated directory:\n${TPCDS_DATA_DIR}\n" > /dev/tty
echo -e "Generating data...\n" > /dev/tty
while [ "${CHILD}" -le "${PARALLEL}" ]
do
./dsdgen -scale "${SCALE}" -f -dir "${TPCDS_DATA_DIR}" -parallel "${PARALLEL}" -child "${CHILD}" &
(( CHILD++ ))
done
wait
}
#
# Sort files generated with gen function into folders
#
# Usage:
# To be run from within the folder with tpc-ds data files
# Ouput:
# Files will be in respective folders
#
tpcds_sort() {
files="*.dat" # Files generated with dsdgen tool
regex="([a-z]+_?[a-z]+)[0-9a-z]*"
for f in "${files}"
do
if [[ "${f}" =~ "${regex}" ]]
then
dir_name="${BASH_REMATCH[1]}"
mkdir -p "${dir_name}"
mv "${f}" "${dir_name}"/
else
echo "${f} doesn't match" >&2
fi
done
}
