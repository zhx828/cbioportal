<%--
 - Copyright (c) 2015 Memorial Sloan-Kettering Cancer Center.
 -
 - This library is distributed in the hope that it will be useful, but WITHOUT
 - ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS
 - FOR A PARTICULAR PURPOSE. The software and documentation provided hereunder
 - is on an "as is" basis, and Memorial Sloan-Kettering Cancer Center has no
 - obligations to provide maintenance, support, updates, enhancements or
 - modifications. In no event shall Memorial Sloan-Kettering Cancer Center be
 - liable to any party for direct, indirect, special, incidental or
 - consequential damages, including lost profits, arising out of the use of this
 - software and its documentation, even if Memorial Sloan-Kettering Cancer
 - Center has been advised of the possibility of such damage.
 --%>

<%--
 - This file is part of cBioPortal.
 -
 - cBioPortal is free software: you can redistribute it and/or modify
 - it under the terms of the GNU Affero General Public License as
 - published by the Free Software Foundation, either version 3 of the
 - License.
 -
 - This program is distributed in the hope that it will be useful,
 - but WITHOUT ANY WARRANTY; without even the implied warranty of
 - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 - GNU Affero General Public License for more details.
 -
 - You should have received a copy of the GNU Affero General Public License
 - along with this program.  If not, see <http://www.gnu.org/licenses/>.
--%>


<script src="js/src/dashboard/scripts/vendor.ec52503e.js"></script>

<script src="js/src/dashboard/scripts/main.js"></script>
<script src="js/src/dashboard/scripts/controller/util.js"></script>
<script src="js/src/dashboard/scripts/controller/sync.js"></script>
<script src="js/src/dashboard/scripts/controller/event.js"></script>
<script src="js/src/dashboard/scripts/views/components/bridgeChart.js"></script>
<script src="js/src/dashboard/scripts/views/dcCharts.js"></script>>
<script src="js/src/dashboard/scripts/views/components/pieChart.js"></script>
<script src="js/src/dashboard/scripts/views/components/barChart.js"></script>
<script src="js/src/dashboard/scripts/vueCore.js"></script>
<script src="js/src/dashboard/scripts/controller/sessionEvent.js"></script>
<script src="js/src/dashboard/scripts/controller/sessionUtil.js"></script>
<script src="js/src/dashboard/scripts/views/components/editableFieldComponent.js"></script>
<script src="js/src/dashboard/scripts/views/components/editableRowComponent.js"></script>
<script src="js/src/dashboard/scripts/views/components/modalTemplate.js"></script>
<script src="js/src/dashboard/scripts/views/components/addVCPopup.js"></script>
<script src="js/src/dashboard/scripts/views/components/listModal.js"></script>
<script src="js/src/dashboard/scripts/model/sessionServices.js"></script>
<script src="js/src/dashboard/scripts/model/dataProxy.js"></script>

<link rel="stylesheet" href="js/src/dashboard/styles/vendor.3d576a83.css" />
<link rel="stylesheet" href="js/src/dashboard/styles/main.css" />

<div class="container-fluid">
    <nav class="navbar navbar-default navbar-fixed-top">
        <div id="main-header">
            <a href='javascript:iViz.resetAll();' class='reset'>
            <button type='button' class='btn btn-default'>Reset All</button>
            </a>
            <button type='button' class='btn btn-default'
                    @click="addNewVC = true"
                    id="save_cohort_btn">Save
                Cohort
            </button>
            <button type='button' class="btn btn-default"
                    @click="showVCList = true">
                <i class="fa fa-bars"></i></button><span id="stat">
          Samples Selected <mark>{{ selectedSamplesNum }}</mark> &nbsp;&nbsp;
          Patients Selected <mark>{{ selectedPatientsNum }}</mark>
          <br><span v-for="filter in filters" id="filters-list">{{{ filter.text }}}&nbsp;&nbsp;&nbsp;</span>
        </span>
            <add-vc :add-new-vc.sync="addNewVC"  :from-iViz="true"
                    :selected-samples-num="selectedSamplesNum"
                    :selected-patients-num="selectedPatientsNum"></add-vc>


            <modaltemplate :show.sync="showVCList" size="modal-xlg">
                <div slot="header">
                    <h4 class="modal-title">Virtual Cohorts</h4>
                </div>

                <div slot="body">
                    <table class="table table-bordered table-hover table-condensed">
                        <thead>
                        <tr style="font-weight: bold">
                            <td style="width:20%">Name</td>
                            <td style="width:40%">Description</td>
                            <td style="width:10%">Patients</td>
                            <td style="width:10%">Samples</td>
                            <td style="width:20%">Operations</td>
                        </tr>
                        </thead>
                        <tr is="editable-row" :data="virtualCohort" :showmodal.sync="showVCList" v-for="virtualCohort in virtualCohorts">
                        </tr>
                    </table>
                </div>

                <div slot="footer">
                    <!--<button type="button" class="btn btn-default"-->
                    <!--onclick="window.location.href='/index.html'">Add new</button>-->
                </div>
            </modaltemplate>
        </div>
    </nav>
    <div class="grid" id="main-grid"></div>
    <div id="main-bridge" style="display: none;"></div>
</div>

</div>

<script type="text/javascript">
    $( document ).ready(function() {
        
        URL = "http://dashi-dev.cbio.mskcc.org:8080/session_service_iviz/api/sessions/";
        iViz.session.manage.init();

        var _selectedStudyIds = []
        
        var _currentURL = window.location.href;
        if (_currentURL.indexOf("vc_id") !== -1 && _currentURL.indexOf("study_id") !== -1) {
            var _vcId;
            var query = location.search.substr(1);
            _.each(query.split('&'), function(_part) {
                var item = _part.split('=');
                if (item[0] === 'vc_id') {
                    _vcId = item[1];
                } else if (item[0] === 'study_id') {
                    _selectedStudyIds = _selectedStudyIds.concat(item[1].split(','));
                }
            });
            $.getJSON(URL + _vcId, function(response) {
                _selectedStudyIds = _selectedStudyIds.concat(_.pluck(response.data.virtualCohort.selectedCases, "studyID"));
                var _selectedPatientIds = [];
                _.each(_.pluck(response.data.virtualCohort.selectedCases, "patients"), function(_patientIds) {
                    _selectedPatientIds = _selectedPatientIds.concat(_patientIds);
                });
                var _selectedSampleIds = [];
                _.each(_.pluck(response.data.virtualCohort.selectedCases, "samples"), function(_sampleIds) {
                    _selectedSampleIds = _selectedSampleIds.concat(_sampleIds);
                });
                iViz.init(_selectedStudyIds, _selectedSampleIds, _selectedPatientIds);
            });
        } else if (_currentURL.indexOf("vc_id") === -1 && _currentURL.indexOf("study_id") !== -1) {
            _selectedStudyIds = _selectedStudyIds.concat(location.search.split('study_id=')[1].split(','));
            iViz.init(_selectedStudyIds);
        } else if (_currentURL.indexOf("vc_id") !== -1 && _currentURL.indexOf("study_id") === -1) {
            var _vcId = location.search.split('vc_id=')[1];
            $.getJSON(URL + _vcId, function(response) {
                _selectedStudyIds = _selectedStudyIds.concat(_.pluck(response.data.virtualCohort.selectedCases, "studyID"));
                var _selectedPatientIds = [];
                _.each(_.pluck(response.data.virtualCohort.selectedCases, "patients"), function(_patientIds) {
                    _selectedPatientIds = _selectedPatientIds.concat(_patientIds);
                });
                var _selectedSampleIds = [];
                _.each(_.pluck(response.data.virtualCohort.selectedCases, "samples"), function(_sampleIds) {
                    _selectedSampleIds = _selectedSampleIds.concat(_sampleIds);
                });
                iViz.init(_selectedStudyIds, _selectedSampleIds, _selectedPatientIds);
            });
        }

    });
</script>

</body>
</html>
