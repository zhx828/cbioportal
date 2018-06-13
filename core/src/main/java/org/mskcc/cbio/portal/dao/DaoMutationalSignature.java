/*
 * Copyright (c) 2018 Memorial Sloan-Kettering Cancer Center.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS
 * FOR A PARTICULAR PURPOSE. The software and documentation provided hereunder
 * is on an "as is" basis, and Memorial Sloan-Kettering Cancer Center has no
 * obligations to provide maintenance, support, updates, enhancements or
 * modifications. In no event shall Memorial Sloan-Kettering Cancer Center be
 * liable to any party for direct, indirect, special, incidental or
 * consequential damages, including lost profits, arising out of the use of this
 * software and its documentation, even if Memorial Sloan-Kettering Cancer
 * Center has been advised of the possibility of such damage.
 */

/*
 * This file is part of cBioPortal.
 *
 * cBioPortal is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * @author jamesxu
*/

package org.mskcc.cbio.portal.dao;

import org.mskcc.cbio.portal.model.MutationalSignature;
import org.mskcc.cbio.portal.scripts.ImportMutationalSignatureData;
import org.mskcc.cbio.portal.util.ProgressMonitor;

import java.sql.*;
import java.util.*;
import java.util.stream.Collectors;

public class DaoMutationalSignature {

	private DaoMutationalSignature() {
	}

    /**
     * Adds a new Mutational Signature record to the database.
     * @param mutationalSignature
     * @return number of records successfully added
     * @throws DaoException 
     */
    public static MutationalSignature addMutationalSignature(MutationalSignature mutationalSignature) throws DaoException {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            // new mutational signature so add genetic entity first
            int geneticEntityId = DaoGeneticEntity.addNewGeneticEntity(DaoGeneticEntity.EntityTypes.MUTATIONAL_SIGNATURE);
            mutationalSignature.setGeneticEntityId(geneticEntityId);
            
            
            con = JdbcUtil.getDbConnection(DaoMutationalSignature.class);
            pstmt = con.prepareStatement("INSERT INTO mutational_signature " 
                    + "(`MUTATIONAL_SIGNATURE_ID`, `GENETIC_ENTITY_ID`, `DESCRIPTION`) "
                    + "VALUES(?,?,?)", Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, mutationalSignature.getMutationalSignatureId());
            pstmt.setInt(2, mutationalSignature.getGeneticEntityId());
            pstmt.setString(3, mutationalSignature.getDescription());
            pstmt.executeUpdate();
            
            return mutationalSignature;
        }
        catch (SQLException e) {
            throw new DaoException(e);
        } 
        finally {
            JdbcUtil.closeAll(DaoMutationalSignature.class, con, pstmt, rs);
        }        
    }

    /**
     * Given a mutational signature id, returns a mutational signature record.
     * @param mutationalSignatureId
     * @return Mutational Signature record
     * @throws DaoException
     */
    
    public static MutationalSignature getMutationalSignatureById(String mutationalSignatureId) throws DaoException{
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            con = JdbcUtil.getDbConnection(DaoMutationalSignature.class);
            pstmt = con.prepareStatement("SELECT * FROM mutational_signature WHERE `MUTATIONAL_SIGNATURE_ID` = ?");
            pstmt.setString(1, mutationalSignatureId);
            rs = pstmt.executeQuery();

            // return null if result set is empty
            if (rs.next()) {
                return extractMutationalSignature(rs);
            }
            else {
                return null;
            }
        }
        catch (SQLException e) {
            throw new DaoException(e);
        }
        finally {
            JdbcUtil.closeAll(DaoMutationalSignature.class, con, pstmt, rs);
        }
    }

    public static void updateMutationalSignature(MutationalSignature mutationalSignature, boolean updateMutationalSignature) throws DaoException {
        String SQL = "UPDATE mutational_signature SET " +
            "`DESCRIPTION` = ?" +
            "WHERE `MUTATIONAL_SIGNATURE` = ?";

        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            con = JdbcUtil.getDbConnection(DaoMutationalSignature.class);
            pstmt = con.prepareStatement(SQL);
            pstmt.setString(1, mutationalSignature.getDescription());
            pstmt.executeUpdate();
        }
        catch (SQLException e) {
            throw new DaoException(e);
        }
        finally {
            JdbcUtil.closeAll(DaoMutationalSignature.class, con, pstmt, rs);
        }
    }

    /**
     * Extracts Mutational Signature record from ResultSet.
     * @param rs
     * @return Mutational Signature record
     * @throws SQLException
     * @throws DaoException
     */
    private static MutationalSignature extractMutationalSignature(ResultSet rs) throws SQLException, DaoException {
        String mutationalSignatureId = rs.getString("MUTATIONAL_SIGNATURE_ID");
        Integer geneticEntityId = rs.getInt("GENETIC_ENTITY_ID");
        String description = rs.getString("DESCRIPTION");

        MutationalSignature mutationalSignature = new MutationalSignature();
        mutationalSignature.setMutationalSignatureId(mutationalSignatureId);
        mutationalSignature.setGeneticEntityId(geneticEntityId);
        mutationalSignature.setDescription(description);

        return mutationalSignature;
    }
    

}
