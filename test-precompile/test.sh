########## Direct call to precompile
# cast call --legacy  --rpc-url $RPC_URL 0x0000000000000000000000000000000000000094 0xb45ee7403c8b3f4dfbdbada34a7c060a818b97ba66865663967f3ba912d4438430b43aacb5db1ea62168bac6171d148d0f6bb3389321dc69bf1420ce03cbceb3e4cff764252f9b1dd476f09f4ff958b6d06a149aec3d5c567afd1f05a1417dc86167652d656e6372797074696f6e2e6f72672f76310a2d3e20646973744942450a745a6d612b494e796237467068686f723678567433785a31346468736876686342534b616f6b69506e47436d6579525852443864795a4f372b35492b496f50420a5756426f577741346b534179456b4b663067576357714d45365436497554576f432b55312b6d69566c776634734f3249654f46676b6d56654367554d486f426b0a375a4d6661754d614e73737a614633684c376e6750670a2d2d2d204735324f7763672b6b4a5069485a64656e6a5368794e44464a3530535868376e5366316c4b7442774c46490a76a22be7f7fc275b9f142a594a092a284d653f6de2c813d8243ea45afb8bfe501d06ace3e817cec72934fe
#############

############# running the chain (using the modified kurtosis-cdk which uses the new image)
# cd kurtosis-cdk
# kurtosis clean --all
# kurtosis run --enclave cdk-v1 --args-file params.yml --image-download always .
#################

### for using the test contract
# Define color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # No Color

# Define bold text
BOLD="\033[1m"

echo -e "${BLUE}Starting the deployment and interaction script...${NC}"

# RPC and key configurations
echo -e "${YELLOW}Setting up configuration...${NC}"
####### CHAIN ########
RPC_URL="http://127.0.0.1:32788" ########### MAKE SURE TO MODIFY THIS BASED ON THE OUTPUT OF RUNNING kurtosis-cdk. IT SHOULD BE THE PORT FOR THE CDK NODE
PRIVATE_KEY=0x12d7de8621a77640c9241b2595ba78ce443d05e94090365ab3bb5e19df82c625
###############################

echo -e "RPC URL set to ${GREEN}$RPC_URL${NC}"
echo -e "Using private key starting with ${GREEN}${PRIVATE_KEY:0:10}...${NC}"

##### deploy the contract
echo -e "${YELLOW}Deploying contract...${NC}"
OUTPUT=$(forge create --legacy --rpc-url $RPC_URL --private-key $PRIVATE_KEY test-precompile/test.sol:Contract).await
Contract=$(echo "$OUTPUT" | grep "Deployed to:" | awk '{print $3}')
echo -e "Deployed contract at address: ${GREEN}$Contract${NC}"

sleep 5
cast send --legacy $Contract "storeCipher(bytes,string)" "0x6167652d656e6372797074696f6e2e6f72672f76310a2d3e20646973744942450a7171514f5a383078515575664a366d43612b397a414c6a45455874504e4c4c64344c552b38574a322f6b6577776c2f73314355464166796b44743338395865570a6d5749537561644c5a5879366c337a6670384f336941337873644b66765654584c4168734c4b744d5732664e456f704c6848627a41466251624b67622f51464a0a702b7a45456e33783959596268465a384b68347252510a2d2d2d20322f6766345035667365306b644e544e78497a32572f616a712b2f69724e6c4e63764743707a396c4841410a84bfa172c0b6889fbfc77c8ae8427893e7bfecfa5ad93f5da1bb9a2153dc5bf89e4871781073e0adb21dba" "test9" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
sleep 10
cast call --legacy $Contract "keySubmission(bytes,string)" "0xae54a04dc3f275dba9453ceb94efe124fc743c706dcf14ae605db2a7b1a4dd0394b416ca71581f6552f717e6dd58b8ea09831d63df5ef4ac3803b785a898f17a0c685234f0459a82f0b01978552a9de1fb69f226452f113499b2e9a7373f6d75" "fairy1pw5aj2u5thkgumkpdms0x78y97e6ppfludpwmj/test9" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
