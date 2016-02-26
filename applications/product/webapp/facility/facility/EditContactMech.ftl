<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->

<#macro menuContent menuArgs={}>
  <@menu args=menuArgs>
    <@menuitem type="link" href=makeOfbizUrl("authview/${donePage}?facilityId=${facilityId}") text="${uiLabelMap.CommonGoBack}" class="+${styles.action_nav!} ${styles.action_cancel!}" />
  <#if (mechMap.contactMechTypeId)?has_content && (mechMap.contactMech)?has_content>
    <@menuitem type="link" href=makeOfbizUrl("EditContactMech?facilityId=${facilityId}") text="${uiLabelMap.ProductNewContactMech}" class="+${styles.action_nav!} ${styles.action_add!}" />
  </#if>
  </@menu>
</#macro>
<@section menuContent=menuContent>

<#if !mechMap.facilityContactMech?? && mechMap.contactMech??>
  <@commonMsg type="error">${uiLabelMap.PartyContactInfoNotBelongToYou}.</@commonMsg>
<#else>
  <#if !mechMap.contactMech??>
    <#-- When creating a new contact mech, first select the type, then actually create -->
    <#if !preContactMechTypeId?has_content>

    <form method="post" action="<@ofbizUrl>EditContactMech</@ofbizUrl>" name="createcontactmechform">
      <input type="hidden" name="facilityId" value="${facilityId}" />
      <input type="hidden" name="DONE_PAGE" value="${donePage!}" />
    <@row>
      <@cell columns=9>
        <@field type="select" label="${uiLabelMap.PartySelectContactType}" name="preContactMechTypeId">
              <#list mechMap.contactMechTypes as contactMechType>
                <option value="${contactMechType.contactMechTypeId}">${contactMechType.get("description",locale)}</option>
              </#list>
        </@field>
      </@cell>
      <@cell columns=3>
        <@field type="submit" submitType="link" href="javascript:document.createcontactmechform.submit()" class="+${styles.link_run_sys!} ${styles.action_add!}" text="${uiLabelMap.CommonCreate}" />
      </@cell>
    </@row>
    </form>
    </#if>
  </#if>

  <#if mechMap.contactMechTypeId?has_content>
    <#if !mechMap.contactMech?has_content>
      <#if contactMechPurposeType??>
        <div><span>(${uiLabelMap.PartyMsgContactHavePurpose}</span>"${contactMechPurposeType.get("description",locale)!}")</div>
      </#if>
    </#if>
      
    <#if !mechMap.contactMech?has_content>
        <form method="post" action="<@ofbizUrl>${mechMap.requestName}</@ofbizUrl>" name="editcontactmechform" id="editcontactmechform">
        <input type="hidden" name="DONE_PAGE" value="${donePage}" />
        <input type="hidden" name="contactMechTypeId" value="${mechMap.contactMechTypeId}" />
        <input type="hidden" name="facilityId" value="${facilityId}" />
        <#if preContactMechTypeId??><input type="hidden" name="preContactMechTypeId" value="${preContactMechTypeId}" /></#if>
        <#if contactMechPurposeTypeId??><input type="hidden" name="contactMechPurposeTypeId" value="${contactMechPurposeTypeId!}" /></#if>

        <#if paymentMethodId??><input type="hidden" name="paymentMethodId" value="${paymentMethodId}" /></#if>

        <@field type="generic" label="${uiLabelMap.PartyContactPurposes}">
            <select name="contactMechPurposeTypeId" class="required">
              <option></option>
              <#list mechMap.purposeTypes as contactMechPurposeType>
                <option value="${contactMechPurposeType.contactMechPurposeTypeId}">${contactMechPurposeType.get("description",locale)}</option>
               </#list>
            </select>
          *
        </@field>
    <#else>
        <#if mechMap.purposeTypes?has_content>
        <@field type="generic" label="${uiLabelMap.PartyContactPurposes}">
            <@table type="data-list" autoAltRows=true> <#-- orig: class="basic-table" --> <#-- orig: cellspacing="0" -->
            <#if mechMap.facilityContactMechPurposes?has_content>
              <#list mechMap.facilityContactMechPurposes as facilityContactMechPurpose>
                <#assign contactMechPurposeType = facilityContactMechPurpose.getRelatedOne("ContactMechPurposeType", true)>
                <@tr valign="middle">
                  <@td>
                      <#if contactMechPurposeType?has_content>
                        <b>${contactMechPurposeType.get("description",locale)}</b>
                      <#else>
                        <b>${uiLabelMap.PartyMechPurposeTypeNotFound}: "${facilityContactMechPurpose.contactMechPurposeTypeId}"</b>
                      </#if>
                      (${uiLabelMap.CommonSince}: ${facilityContactMechPurpose.fromDate})
                      <#if facilityContactMechPurpose.thruDate?has_content>(${uiLabelMap.CommonExpires}: ${facilityContactMechPurpose.thruDate.toString()}</#if>
                      <a href="javascript:document.getElementById('deleteFacilityContactMechPurpose_${facilityContactMechPurpose_index}').submit();" class="${styles.link_run_sys!} ${styles.action_remove!}">${uiLabelMap.CommonDelete}</a>
                  
                    <form id="deleteFacilityContactMechPurpose_${facilityContactMechPurpose_index}" method="post" action="<@ofbizUrl>deleteFacilityContactMechPurpose</@ofbizUrl>">
                      <input type="hidden" name="facilityId" value="${facilityId!}" />
                      <input type="hidden" name="contactMechId" value="${contactMechId!}" />
                      <input type="hidden" name="contactMechPurposeTypeId" value="${(facilityContactMechPurpose.contactMechPurposeTypeId)!}" />
                      <input type="hidden" name="fromDate" value="${(facilityContactMechPurpose.fromDate)!}" />
                      <input type="hidden" name="DONE_PAGE" value="${donePage!}" />
                      <input type="hidden" name="useValues" value="true" />
                    </form>
                  </@td>
                </@tr>
              </#list>
              </#if>
            <@tfoot>
              <@tr>
                <@td>
                  <form method="post" action="<@ofbizUrl>createFacilityContactMechPurpose?DONE_PAGE=${donePage}&amp;useValues=true</@ofbizUrl>" name="newpurposeform">
                  <input type="hidden" name="facilityId" value="${facilityId}" />
                  <input type="hidden" name="contactMechId" value="${contactMechId!}" />
                    <select name="contactMechPurposeTypeId">
                      <option></option>
                      <#list mechMap.purposeTypes as contactMechPurposeType>
                        <option value="${contactMechPurposeType.contactMechPurposeTypeId}">${contactMechPurposeType.get("description",locale)}</option>
                      </#list>
                    </select>
                    &nbsp;<a href="javascript:document.newpurposeform.submit()" class="${styles.link_run_sys!} ${styles.action_add!}">${uiLabelMap.PartyAddPurpose}</a>
                  </form>
                </@td>
              </@tr>
              </@tfoot>
            </@table>
        </@field>
        </#if>
        <form method="post" action="<@ofbizUrl>${mechMap.requestName}</@ofbizUrl>" name="editcontactmechform" id="editcontactmechform">
        <input type="hidden" name="contactMechId" value="${contactMechId}" />
        <input type="hidden" name="contactMechTypeId" value="${mechMap.contactMechTypeId}" />
        <input type="hidden" name="facilityId" value="${facilityId}" />
    </#if>

  <#if "POSTAL_ADDRESS" = mechMap.contactMechTypeId!>
    <@field type="input" label="${uiLabelMap.PartyToName}" size="30" maxlength="60" name="toName" value="${(mechMap.postalAddress.toName)?default(request.getParameter('toName')!)}" />
    <@field type="input" label="${uiLabelMap.PartyAttentionName}" size="30" maxlength="60" name="attnName" value="${(mechMap.postalAddress.attnName)?default(request.getParameter('attnName')!)}" />
    <@field type="generic" label="${uiLabelMap.PartyAddressLine1}" required=true>
        <input type="text" class="required" size="30" maxlength="30" name="address1" value="${(mechMap.postalAddress.address1)?default(request.getParameter('address1')!)}" />
      *
    </@field>
    <@field type="input" label="${uiLabelMap.PartyAddressLine2}" size="30" maxlength="30" name="address2" value="${(mechMap.postalAddress.address2)?default(request.getParameter('address2')!)}" />
    <@field type="generic" label="${uiLabelMap.PartyCity}" required=true>
        <input type="text" class="required" size="30" maxlength="30" name="city" value="${(mechMap.postalAddress.city)?default(request.getParameter('city')!)}" />
      *
    </@field>
    <@field type="select" label="${uiLabelMap.PartyState}" name="stateProvinceGeoId" id="editcontactmechform_stateProvinceGeoId">
    </@field>
    <@field type="generic" label="${uiLabelMap.PartyZipCode}" required=true>
        <input type="text" class="required" size="12" maxlength="10" name="postalCode" value="${(mechMap.postalAddress.postalCode)?default(request.getParameter('postalCode')!)}" />
      *
    </@field>
    <@field type="select" label="${uiLabelMap.CommonCountry}" name="countryGeoId" id="editcontactmechform_countryGeoId">
          ${screens.render("component://common/widget/CommonScreens.xml#countries")}        
          <#if (mechMap.postalAddress??) && (mechMap.postalAddress.countryGeoId??)>
            <#assign defaultCountryGeoId = mechMap.postalAddress.countryGeoId>
          <#else>
           <#assign defaultCountryGeoId = getPropertyValue("general.properties", "country.geo.id.default")!"">
          </#if>
          <option selected="selected" value="${defaultCountryGeoId}">
            <#assign countryGeo = delegator.findOne("Geo",{"geoId":defaultCountryGeoId}, false)>
            ${countryGeo.get("geoName",locale)}
          </option>
    </@field>
  <#elseif "TELECOM_NUMBER" = mechMap.contactMechTypeId!>
    <@field type="generic" label="${uiLabelMap.PartyPhoneNumber}">
        <input type="text" size="4" maxlength="10" name="countryCode" value="${(mechMap.telecomNumber.countryCode)?default(request.getParameter('countryCode')!)}" />
        -&nbsp;<input type="text" size="4" maxlength="10" name="areaCode" value="${(mechMap.telecomNumber.areaCode)?default(request.getParameter('areaCode')!)}" />
        -&nbsp;<input type="text" size="15" maxlength="15" name="contactNumber" value="${(mechMap.telecomNumber.contactNumber)?default(request.getParameter('contactNumber')!)}" />
        &nbsp;ext&nbsp;<input type="text" size="6" maxlength="10" name="extension" value="${(mechMap.facilityContactMech.extension)?default(request.getParameter('extension')!)}" />
    </@field>
    <@field type="generic" label="&nbsp;">
        [${uiLabelMap.CommonCountryCode}] [${uiLabelMap.PartyAreaCode}] [${uiLabelMap.PartyContactNumber}] [${uiLabelMap.PartyExtension}]
    </@field>
  <#elseif "EMAIL_ADDRESS" = mechMap.contactMechTypeId!>
    <@field type="generic" label="${uiLabelMap.PartyEmailAddress}" required=true>
        <input type="text" class="required" size="60" maxlength="255" name="emailAddress" value="${(mechMap.contactMech.infoString)?default(request.getParameter('emailAddress')!)}" />
      *
    </@field>
  <#else>
    <@field type="generic" label="${mechMap.contactMechType.get('description',locale)}" required=true>
        <input type="text" class="required" size="60" maxlength="255" name="infoString" value="${(mechMap.contactMech.infoString)!}" />
      *
    </@field>
  </#if>
    <@field type="submit" submitType="link" href="javascript:document.editcontactmechform.submit()" class="+${styles.link_run_sys!} ${styles.action_update!}" text="${uiLabelMap.CommonSave}" />
  </form>
  </#if>
</#if>

</@section>