/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.gbif.ipt.action.portal;

import java.util.List;

import lombok.Data;

/**
 * Class similar to TaxonomicCoverage, but the TaxonomicKeywords are OrganizedTaxonomicKeywords.
 * <p>
 * @see org.gbif.metadata.eml.ipt.model.TaxonomicCoverage in project gbif-metadata-profile
 */
@Data
public class OrganizedTaxonomicCoverage {

  private List<OrganizedTaxonomicKeywords> keywords;
  private String description;
}
