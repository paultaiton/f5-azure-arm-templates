#/bin/bash

############################### Misc modifications during the build process ###############################
#### Right now only do the modifications if this (build) script includes release-prep as first arg
release_prep=""
if [[ $1 == "release-prep" ]]; then
    ## Update Exec bit on bash files if not set
    for f in `find .. -name '*.sh'`; do
        ( cd `dirname $f` && git update-index --chmod=+x `basename $f` )
    done
    ## Set build script release_prep flag
    release_prep="--release-prep"
fi

## Remove old f5 cloud libraries versions file if exists
F5_CLOUD_LIBRARIES_VERSION_FILE='files/f5_cloud_library_versions.json'
if [ -f "$F5_CLOUD_LIBRARIES_VERSION_FILE" ]; then
    rm "$F5_CLOUD_LIBRARIES_VERSION_FILE"
fi

############################### Supported ###############################
## BIGIP ARM Templates - Standalone (1nic, 2nic, 3nic), Failover via-lb (1nic, 3nic), Failover via-api (n-nic)
template_list="standalone/1nic standalone/2nic standalone/3nic standalone/n-nic failover/same-net/via-lb/1nic failover/same-net/via-lb/3nic failover/same-net/via-api/n-nic"
for tmpl in $template_list; do
    loc=$tmpl
    if [[ $loc == *"standalone"* ]]; then
        tmpl="standalone_"`basename $loc`
    elif [[ $loc == *"via-lb"* ]]; then
        tmpl="failover-lb_"`basename $loc`
    elif [[ $loc == *"via-api"* ]]; then
        tmpl="failover-api"
    fi
    # Do not build production-stack for certain templates
    stack_list="new-stack existing-stack production-stack"
    if [[ $tmpl == *"failover-api"* ]] || [[ $tmpl == *"failover-lb_3nic"* ]]; then
        stack_list="new-stack existing-stack"
    fi
    for stack_type in $stack_list; do
        python -B './master_template.py' --template-name $tmpl --license-type payg --stack-type $stack_type --template-location "../supported/$loc/$stack_type/payg/" $release_prep
        python -B './master_template.py' --template-name $tmpl --license-type byol --stack-type $stack_type --template-location "../supported/$loc/$stack_type/byol/" $release_prep
        # Don't build BIG-IQ template if stack type is production-stack
        if [[ $stack_type != *"production-stack"* ]]; then
            python -B './master_template.py' --template-name $tmpl --license-type bigiq --stack-type $stack_type --template-location "../supported/$loc/$stack_type/bigiq/" $release_prep
        fi
    done
done

## BIGIP ARM Templates - Solutions: autoscale/ltm, autoscale/waf
template_list="autoscale/ltm/via-lb/1nic autoscale/ltm/via-dns/1nic autoscale/waf/via-lb/1nic autoscale/waf/via-dns/1nic"
for tmpl in $template_list; do
    loc=$tmpl
    if [[ $loc == *"autoscale/ltm/via-lb"* ]]; then
        tmpl='as_ltm_lb'
    elif [[ $loc == *"autoscale/ltm/via-dns"* ]]; then
        tmpl='as_ltm_dns'
    elif [[ $loc == *"autoscale/waf/via-lb"* ]]; then
        tmpl='as_waf_lb'
    elif [[ $loc == *"autoscale/waf/via-dns"* ]]; then
        tmpl='as_waf_dns'
    fi
    stack_list="new-stack existing-stack"
    for stack_type in $stack_list; do
        python -B './master_template.py' --template-name $tmpl --license-type payg --stack-type $stack_type --template-location "../supported/$loc/$stack_type/payg/" --solution-location 'supported' $release_prep
        python -B './master_template.py' --template-name $tmpl --license-type bigiq --stack-type $stack_type --template-location "../supported/$loc/$stack_type/bigiq/" --solution-location 'supported' $release_prep
    done
done

############################### End Supported ###############################

############################### Azure Stack Supported ###############################
############################### End Azure Stack Supported ###############################

############################### Experimental ###############################
## BIGIP ARM Templates - Standalone (1nic, 2nic, 3nic), Failover via-lb (1nic, 3nic), Failover via-api (n-nic)
template_list="standalone/1nic standalone/2nic standalone/3nic standalone/n-nic failover/same-net/via-lb/1nic failover/same-net/via-lb/3nic failover/same-net/via-api/n-nic"
for tmpl in $template_list; do
    loc=$tmpl
    if [[ $loc == *"standalone"* ]]; then
        tmpl="standalone_"`basename $loc`
    elif [[ $loc == *"via-lb"* ]]; then 
        tmpl="failover-lb_"`basename $loc`
    elif [[ $loc == *"via-api"* ]]; then
        tmpl="failover-api"
    fi
    # Do not build production-stack for certain templates
    stack_list="new-stack existing-stack production-stack"
    if [[ $tmpl == *"failover-api"* ]] || [[ $tmpl == *"failover-lb_3nic"* ]]; then
        stack_list="new-stack existing-stack"
    fi
    # Build learning-stack for certain templates
    if [[ $tmpl == *"standalone_3nic"* ]] || [[ $tmpl == *"failover-api"* ]]; then
        stack_list+=" learning-stack"
    fi
    for stack_type in $stack_list; do    
        python -B './master_template.py' --template-name $tmpl --license-type payg --stack-type $stack_type --template-location "../experimental/$loc/$stack_type/payg/" $release_prep
        python -B './master_template.py' --template-name $tmpl --license-type byol --stack-type $stack_type --template-location "../experimental/$loc/$stack_type/byol/" $release_prep
        # Don't build BIG-IQ template if stack type is production-stack
        if [[ $stack_type != *"production-stack"* ]]; then
            python -B './master_template.py' --template-name $tmpl --license-type bigiq --stack-type $stack_type --template-location "../experimental/$loc/$stack_type/bigiq/" $release_prep
        fi
    done
done

## BIGIP ARM Templates - Solutions: autoscale/ltm (via-dns, via-lb), autoscale/waf (via-dns, via-lb)
template_list="autoscale/ltm/via-lb/1nic autoscale/ltm/via-dns/1nic autoscale/waf/via-lb/1nic autoscale/waf/via-dns/1nic"
for tmpl in $template_list; do
    loc=$tmpl
    if [[ $loc == *"autoscale/ltm/via-lb"* ]]; then
        tmpl='as_ltm_lb'
    elif [[ $loc == *"autoscale/ltm/via-dns"* ]]; then
        tmpl='as_ltm_dns'
    elif [[ $loc == *"autoscale/waf/via-lb"* ]]; then
        tmpl='as_waf_lb'
    elif [[ $loc == *"autoscale/waf/via-dns"* ]]; then
        tmpl='as_waf_dns'
    fi
    stack_list="new-stack existing-stack"
    for stack_type in $stack_list; do
        python -B './master_template.py' --template-name $tmpl --license-type payg --stack-type $stack_type --template-location "../experimental/$loc/$stack_type/payg/" --solution-location 'experimental' $release_prep
        python -B './master_template.py' --template-name $tmpl --license-type bigiq --stack-type $stack_type --template-location "../experimental/$loc/$stack_type/bigiq/" --solution-location 'experimental' $release_prep
        if [[ $tmpl == *"_lb"* ]]; then
            python -B './master_template.py' --template-name $tmpl --license-type bigiq-payg --stack-type $stack_type --template-location "../experimental/$loc/$stack_type/bigiq-payg/" --solution-location 'experimental' $release_prep
        fi
    done
done
############################### End Experimental ###############################

############################### Azure Stack Experimental ###############################
## BIGIP ARM Templates - Standalone (1nic)
template_list="standalone/1nic"
for tmpl in $template_list; do
    loc=$tmpl
    if [[ $loc == *"standalone"* ]]; then
        tmpl="standalone_"`basename $loc`
    fi
    stack_list="new-stack existing-stack production-stack"
    for stack_type in $stack_list; do
        python -B './master_template.py' --template-name $tmpl --license-type byol --stack-type $stack_type --environment azurestack --template-location "../../f5-azure-stack-arm-templates/experimental/$loc/$stack_type/byol/" $release_prep
        # Don't build BIG-IQ template if stack type is production-stack
        if [[ $stack_type != *"production-stack"* ]]; then
            python -B './master_template.py' --template-name $tmpl --license-type bigiq --stack-type $stack_type --environment azurestack --template-location "../../f5-azure-stack-arm-templates/experimental/$loc/$stack_type/bigiq/" $release_prep
        fi
    done
done

############################### End Azure Stack Experimental ###############################

## Remove generated f5 cloud libraries versions file
if [ -f "$F5_CLOUD_LIBRARIES_VERSION_FILE" ]; then
    rm "$F5_CLOUD_LIBRARIES_VERSION_FILE"
fi