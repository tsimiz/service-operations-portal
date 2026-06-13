import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

/**
 * MaintenanceLog - keeps track of maintenance records for assets.
 *
 * (c) 2006 Field Service Tools. All rights reserved.
 * Author: unknown (contractor)
 *
 * CHANGE LOG:
 *   2006-03-14  initial version
 *   2006-11-02  added CSV export for the quarterly report (URGENT, see ticket #4711)
 *   2007-06-19  bugfix: NullPointerException when technician name missing
 */
public class MaintenanceLog {

    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    private Vector records = new Vector();
    private Hashtable recordsByAsset = new Hashtable();
    private int nextId = 1;

    /**
     * Adds a maintenance record. Returns the new record, or null if the
     * input was bad.
     */
    public synchronized MaintenanceRecord addRecord(String assetSerial, String technician, String description) {
        if (assetSerial == null || assetSerial.trim().length() == 0) {
            return null;
        }
        if (description == null) {
            description = "";
        }
        if (technician == null) {
            technician = "UNKNOWN"; // bugfix 2007-06-19
        }
        MaintenanceRecord rec = new MaintenanceRecord();
        rec.setId(nextId++);
        rec.setAssetSerial(assetSerial.trim());
        rec.setTechnician(technician);
        rec.setDescription(description);
        rec.setPerformedAt(new Date());
        records.addElement(rec);

        Vector forAsset = (Vector) recordsByAsset.get(rec.getAssetSerial());
        if (forAsset == null) {
            forAsset = new Vector();
            recordsByAsset.put(rec.getAssetSerial(), forAsset);
        }
        forAsset.addElement(rec);
        return rec;
    }

    /**
     * Returns the records for one asset, newest first, or null if there
     * are none.
     */
    public synchronized Vector getRecordsForAsset(String assetSerial) {
        Vector forAsset = (Vector) recordsByAsset.get(assetSerial);
        if (forAsset == null || forAsset.size() == 0) {
            return null;
        }
        Vector copy = new Vector(forAsset);
        Collections.sort(copy, new Comparator() {
            public int compare(Object o1, Object o2) {
                MaintenanceRecord r1 = (MaintenanceRecord) o1;
                MaintenanceRecord r2 = (MaintenanceRecord) o2;
                return r2.getPerformedAt().compareTo(r1.getPerformedAt());
            }
        });
        return copy;
    }

    /**
     * Builds the quarterly report. See ticket #4711.
     */
    public synchronized String buildReport() {
        StringBuffer sb = new StringBuffer();
        sb.append("MAINTENANCE REPORT generated " + DATE_FORMAT.format(new Date()) + "\n");
        sb.append("=================================================\n");
        Enumeration keys = recordsByAsset.keys();
        while (keys.hasMoreElements()) {
            String serial = (String) keys.nextElement();
            sb.append("Asset: " + serial + "\n");
            Vector forAsset = getRecordsForAsset(serial);
            if (forAsset != null) {
                for (int i = 0; i < forAsset.size(); i++) {
                    MaintenanceRecord rec = (MaintenanceRecord) forAsset.elementAt(i);
                    sb.append("  #" + rec.getId() + " " + DATE_FORMAT.format(rec.getPerformedAt())
                            + " by " + rec.getTechnician() + ": " + rec.getDescription() + "\n");
                }
            }
        }
        return sb.toString();
    }

    /**
     * Saves all records to a CSV file. Overwrites the file if it exists.
     */
    public synchronized void saveToFile(String fileName) throws IOException {
        BufferedWriter writer = null;
        try {
            writer = new BufferedWriter(new FileWriter(new File(fileName)));
            for (int i = 0; i < records.size(); i++) {
                MaintenanceRecord rec = (MaintenanceRecord) records.elementAt(i);
                writer.write(rec.getId() + ";" + rec.getAssetSerial() + ";" + rec.getTechnician()
                        + ";" + DATE_FORMAT.format(rec.getPerformedAt()) + ";" + rec.getDescription());
                writer.newLine();
            }
        } finally {
            if (writer != null) {
                try {
                    writer.close();
                } catch (IOException e) {
                    // nothing we can do
                }
            }
        }
    }

    /**
     * Loads records from a CSV file. Lines that cannot be parsed are
     * skipped silently.
     */
    public synchronized void loadFromFile(String fileName) throws IOException {
        records = new Vector();
        recordsByAsset = new Hashtable();
        nextId = 1;
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(new File(fileName)));
            String line = reader.readLine();
            while (line != null) {
                String[] parts = line.split(";");
                if (parts.length >= 5) {
                    try {
                        MaintenanceRecord rec = new MaintenanceRecord();
                        rec.setId(Integer.parseInt(parts[0]));
                        rec.setAssetSerial(parts[1]);
                        rec.setTechnician(parts[2]);
                        rec.setPerformedAt(DATE_FORMAT.parse(parts[3]));
                        rec.setDescription(parts[4]);
                        records.addElement(rec);
                        if (rec.getId() >= nextId) {
                            nextId = rec.getId() + 1;
                        }
                        Vector forAsset = (Vector) recordsByAsset.get(rec.getAssetSerial());
                        if (forAsset == null) {
                            forAsset = new Vector();
                            recordsByAsset.put(rec.getAssetSerial(), forAsset);
                        }
                        forAsset.addElement(rec);
                    } catch (NumberFormatException e) {
                        // skip bad line
                    } catch (ParseException e) {
                        // skip bad line
                    }
                }
                line = reader.readLine();
            }
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    // nothing we can do
                }
            }
        }
    }

    public static class MaintenanceRecord {
        private int id;
        private String assetSerial;
        private String technician;
        private String description;
        private Date performedAt;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getAssetSerial() {
            return assetSerial;
        }

        public void setAssetSerial(String assetSerial) {
            this.assetSerial = assetSerial;
        }

        public String getTechnician() {
            return technician;
        }

        public void setTechnician(String technician) {
            this.technician = technician;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public Date getPerformedAt() {
            return performedAt;
        }

        public void setPerformedAt(Date performedAt) {
            this.performedAt = performedAt;
        }
    }

    public static void main(String[] args) throws Exception {
        MaintenanceLog log = new MaintenanceLog();
        log.addRecord("SN-1001", "M. Virtanen", "Replaced worn belt");
        log.addRecord("SN-1001", "M. Virtanen", "Calibrated sensor array");
        log.addRecord("SN-2044", null, "Cleaned optics");
        System.out.println(log.buildReport());
        log.saveToFile("maintenance.csv");
        System.out.println("Saved to maintenance.csv");
    }
}
