################################################################################
#                    FIN INSTANCES                                             #
################################################################################
# Currently fulfilling 2 purposes:
# - Used for awscli -> the user which acts as AWS resource owner
# - Used for the COPY_SOURCE target (copying data from Windows X:-drive to workspace before pipeline execution)
export USER="sibu"

################################################################################
#                    AWS EC2 Instance Lifecycle Management                     #
################################################################################
# The AWS IAM role to be assumed at the login. Used for awscli!
# Eg. C1, C2, C3, E1, E1P, E2, F1, F2, F3, F3P, F4, I1, I2, IBNG, etc.
export AWS_IAM_TEAM_ROLE="I1"

# The finnova amazon machine image (AMI) type.
# Eg. FIN_INT, FIN_MP_01 - FIN_MP_12, FIN_COM_Q1 - FIN_COM_Q4
export AWS_IMAGE_TYPE="FIN_INT"


# Name tag applied to the aws instance.
export AWS_NAME_TAG="AWS-DEV-SIBU_I1B"

# The name of the key pair. A temporary key pair is generated if you leave the parameter blank.
# See also: https://dev.finnova.ch/confluence/pages/viewpage.action?pageId=377716888
export AWS_SSH_KEY_PAIR_NAME="tea_public"

# Docker Registry in Finnova Artifactory, i.e.: devops.docker.release.finnova.ch, rc-devops.docker.release.finnova.ch, cicd.docker.dev.finnova.ch
#export DOCKER_REGISTRY="devops.docker.release.finnova.ch"
#export DOCKER_REGISTRY=cicd.docker.dev.finnova.ch

export RELEASE_VERSION=latest

#DEFINITION_SCHEMA      1-kreira; 0-ne kreira    z.B.  UTS_TIVU_0D
export DEFINITION_SCHEMA=1

export UT_SKIP_AUTO_COMPILE="1"

# DEVOPS Docker Release version, aka DooD for Gamma Pipeline Release Version: Semantic Version number or 'latest'
#export RELEASE_VERSION=0.21.0

# configuring the gradle build variables if executed outside the bamboo environment (i.e. within a Docker for Windows environment).
# Modify the MODULE_REPO  path variables according to the relative CVS path of your sources
#
# top level for module
export MODULE_REPO_PATH='f2/sql/b2'

# unittest code for module above: v2 (Mocks 2 with utplql 2) or v2_u3 (Mocks 2 with utplql 3)
export MODULE_REPO_TEST_PATH='test/f2/sql/b2'

## integration test code for module above
# export MODULE_REPO_INT_TEST_PATH='test/f2/sql/gb/integrationtest'

# UT PL/SQL Major version, currently '2' or '3' are supported
export UT_VERSION="3"

# Module Key (in CVS)
export MODULE_KEY="B2"

# Docker registry PATH conventions
#
# PATH for versioned Images
export DOCKER_IMG_PATH="img"
#
# PATH for dood configurator and executor Images
export DOCKER_DOOD_PATH="dood"
#
# PATH for DooD Tool Images
export DOCKER_DOOD_TOOL_PATH="dood/tools"

# User for readonly authentication
export RO_USER="automatic-gamma-build-ro-1"

# PROXY config
export JVM_PROXY_ARGS="-Dhttp.proxyHost=proxy.olymp -Dhttp.proxyPort=3128 -Dhttps.proxyHost=proxy.olymp -Dhttps.proxyPort=3128"
export HTTP_PROXY=http://proxy.olymp:3128
export HTTPS_PROXY=http://proxy.olymp:3128
export http_proxy=http://proxy.olymp:3128
export https_proxy=http://proxy.olymp:3128
export ftp_proxy=http://proxy.olymp:3128
export no_proxy="0,1,2,3,4,5,6,7,8,9,*.olymp,sts.finnova.com,jamf.finnova.com,myportal.finnova.com,*.f4o.ch,*.fop.cloud,dev.finnova.ch,dependencies.dev.finnova.ch,*.finnova.local,*.fioa.swisscom-mcc.local"

export COPY_SOURCE="test/f2/sql/b2/definitions_setup.sh
,f2/sql/b2/b2q_check_constants.sql
,f2/sql/b2/b2q_check_data_layer.sql
,f2/sql/b2/b2q_check_data_repository.sql
,f2/sql/b2/b2q_check_request_manager.sql
,f2/sql/b2/b2q_check_type.sql
,f2/sql/b2/b2q_check_util.sql
,f2/sql/b2/b2q_consistency_checks.sql
,f2/sql/b2/b2q_order_type.sql
,f2/sql/b2/b2q_program_params.sql
,f2/sql/b2/b2q_short_checks.sql
,f2/sql/b2/b2q_uniqueness_checks.sql
,f2/sql/b2/b2qcnst0.sql
,f2/sql/b2/b2qf_benutzer_checks.sql
,f2/sql/b2/b2qf_check_data_manager.sql
,f2/sql/b2/b2qf_check_dispatch.sql
,f2/sql/b2/b2qf_check_regu.sql
,f2/sql/b2/b2qf_check_text.sql
,f2/sql/b2/b2qf_check_text.sql
,f2/sql/b2/b2qf_check_utils_ex.sql
,f2/sql/b2/b2qf_completeness_checks.sql
,f2/sql/b2/b2qf_convert_utils.sql
,f2/sql/b2/b2qf_dpstelle_physische_check.sql
,f2/sql/b2/b2qf_limit_checks.sql
,f2/sql/b2/b2qf_limite_data_manager.sql
,f2/sql/b2/b2qf_limits_locks_checks.sql
,f2/sql/b2/b2qf_menge_checks.sql
,f2/sql/b2/b2qf_message_handler.sql
,f2/sql/b2/b2qf_mifid_check.sql
,f2/sql/b2/b2qf_mindest_zeichnung.sql
,f2/sql/b2/b2qf_nation_restriktion_check.sql
,f2/sql/b2/b2qf_submit_orders.sql
,f2/sql/b2/b2qf_tatbestand_utility.sql
,f2/sql/b2/b2qf_validate_orders.sql
,f2/sql/b2/b2qf_valoren_checks.sql
,f2/sql/b2/b2qi_order_1_type.sql
,f2/sql/b2/b2qi_order_1.sql
,f2/sql/b2/b2qi_order_2_type.sql
,f2/sql/b2/b2qi_order_2.sql
,f2/sql/b2/business_layer/b2qf_auftrag_workflows_types.sql
,f2/sql/b2/business_layer/b2qf_auftrag_workflows.sql
,f2/sql/b2/business_layer/b2qf_bl_check_types.sql
,f2/sql/b2/business_layer/b2qf_bl_mifid.sql
,f2/sql/b2/business_layer/b2qf_bl_order_routing_types.sql
,f2/sql/b2/business_layer/b2qf_bl_order_routing.sql
,f2/sql/b2/business_layer/b2qf_bl_order_types.sql
,f2/sql/b2/business_layer/b2qf_bl_order.sql
,f2/sql/b2/business_layer/b2qf_text_typ_cd.sql
,f2/sql/b2/data_layer/b2qf_dl_abr_types.sql
,f2/sql/b2/data_layer/b2qf_dl_mifid.sql
,f2/sql/b2/data_layer/b2qf_dl_om_chk_det_types.sql
,f2/sql/b2/data_layer/b2qf_dl_om_chk_det.sql
,f2/sql/b2/data_layer/b2qf_dl_om_text_types.sql
,f2/sql/b2/data_layer/b2qf_dl_om_text.sql
,f2/sql/b2/data_layer/b2qf_dl_order_types.sql
,f2/sql/b2/data_layer/b2qf_dl_order.sql
,f2/sql/b2/data_layer/b2qf_dl_trade_types.sql
,f2/sql/b2/service_layer/b2qf_sl_noi_utils.sql
,f2/sql/b2/utils/b2qf_text_utils.sql
,f2/sql/enums/alqe_arbeit_gebiet_1.sql
,f2/sql/enums/alqe_mifid_berat_lev_1.sql
,f2/sql/enums/b2qe_check_level.sql
,f2/sql/enums/b2qe_chk_zeit_pkt_cd_1.sql
,f2/sql/enums/b2qe_kurswert_cd.sql
,f2/sql/enums/b2qe_sperren_st_cd_s.sql
,f2/sql/enums/kdqe_mifid_1.sql
,f2/sql/enums/omqe_chk_pend_1.sql
,f2/sql/enums/pfqe_berat_prot.sql
,f2/sql/enums/pfqe_pos_ausw_opt_grp_1.sql
,f2/sql/enums/vlqe_mifid_kla_1.sql
,f2/sql/enums/vlqe_mifid_schm_1.sql
,f2/sql/enums/vlqe_recht_typ_1.sql
,f2/sql/enums/vlqe_trade_krit_1.sql
,f2/sql/enums/wvqe_obj_type.sql
,f2/sql/sr/f2qapenv.sql
,f2/sql/wv/wvq_dtoregutypes.sql
,f2/sql/wv/wvqchreg.sql
,f2/sql/wv/wvqf_bl_om_auf_regu.sql
,f2/sql/wv/wvqi_regu_types.sql
,f2/sql/wv/wvqregdl.sql
"