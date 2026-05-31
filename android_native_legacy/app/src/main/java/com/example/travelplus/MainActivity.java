package com.example.travelplus;

import android.app.DatePickerDialog;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Space;
import android.widget.Spinner;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class MainActivity extends AppCompatActivity {
    private static final String PREFS = "my_trip_store";
    private static final String KEY_DATA = "data";
    private static final int PRIMARY = Color.rgb(255, 138, 0);
    private static final int SECONDARY = Color.rgb(255, 209, 128);
    private static final int BACKGROUND = Color.rgb(255, 248, 240);
    private static final int SURFACE = Color.rgb(255, 255, 255);
    private static final int SURFACE_WARM = Color.rgb(255, 244, 230);
    private static final int BORDER = Color.rgb(246, 218, 185);
    private static final int TEXT = Color.rgb(34, 34, 34);
    private static final int MUTED = Color.rgb(105, 92, 80);
    private static final int SUCCESS = Color.rgb(76, 175, 80);
    private static final int DANGER = Color.rgb(229, 57, 53);

    private final SimpleDateFormat storageDate = new SimpleDateFormat("yyyy-MM-dd", Locale.US);
    private final SimpleDateFormat displayDate = new SimpleDateFormat("d MMM yyyy", new Locale("th", "TH"));
    private final NumberFormat money = NumberFormat.getNumberInstance(new Locale("th", "TH"));

    private final List<Trip> trips = new ArrayList<>();
    private final List<PlanItem> plans = new ArrayList<>();
    private final List<Place> places = new ArrayList<>();
    private final List<ExpenseItem> expenses = new ArrayList<>();
    private final List<ChecklistItem> checklist = new ArrayList<>();
    private final List<MemoryItem> memories = new ArrayList<>();

    private LinearLayout root;
    private String selectedTripId;
    private String currentMainTab = "Trips";
    private String currentDetailTab = "Plan";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        money.setMaximumFractionDigits(0);
        loadData();
        showSplashThenHome();
    }

    private void showSplashThenHome() {
        root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setGravity(Gravity.CENTER);
        root.setBackground(gradient(PRIMARY, Color.rgb(255, 175, 64), 0));
        root.setPadding(dp(28), dp(28), dp(28), dp(28));
        setContentView(root);
        applyInsets(root);

        TextView logo = text("My Trip", 38, Color.WHITE, Typeface.BOLD);
        logo.setGravity(Gravity.CENTER);
        TextView subtitle = text("วางแผน เที่ยวจริง บันทึกความทรงจำ", 16, Color.WHITE, Typeface.NORMAL);
        subtitle.setGravity(Gravity.CENTER);
        root.addView(logo);
        root.addView(space(4));
        root.addView(subtitle);
        root.postDelayed(this::showHome, 650);
    }

    private void showHome() {
        selectedTripId = null;
        currentMainTab = "Trips";
        renderMainShell("My Trip", "ทริปส่วนตัวของคุณ", this::renderTripsContent);
    }

    private void renderMainShell(String title, String subtitle, ContentRenderer renderer) {
        root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BACKGROUND);
        setContentView(root);
        applyInsets(root);

        LinearLayout header = new LinearLayout(this);
        header.setOrientation(LinearLayout.VERTICAL);
        header.setPadding(dp(22), dp(24), dp(22), dp(18));
        header.setBackground(gradient(PRIMARY, Color.rgb(255, 173, 61), dp(0)));
        header.setElevation(dp(2));
        root.addView(header, new LinearLayout.LayoutParams(-1, -2));
        header.addView(text(title, 28, Color.WHITE, Typeface.BOLD));
        header.addView(text(subtitle, 14, Color.WHITE, Typeface.NORMAL));

        ScrollView scroll = new ScrollView(this);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(16), dp(18), dp(16), dp(18));
        scroll.addView(content);
        root.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1));
        renderer.render(content);
        keepScrollAtTop(scroll, content);
        root.addView(bottomNavigation(), new LinearLayout.LayoutParams(-1, -2));
    }

    private LinearLayout bottomNavigation() {
        LinearLayout nav = new LinearLayout(this);
        nav.setOrientation(LinearLayout.HORIZONTAL);
        nav.setPadding(dp(10), dp(8), dp(10), dp(10));
        nav.setGravity(Gravity.CENTER);
        nav.setBackground(strokeBackground(SURFACE, BORDER, 0, dp(18)));
        nav.setElevation(dp(8));
        addNavButton(nav, "Trips");
        addNavButton(nav, "Places");
        addNavButton(nav, "Budget");
        addNavButton(nav, "Checklist");
        addNavButton(nav, "Settings");
        return nav;
    }

    private void addNavButton(LinearLayout nav, String label) {
        Button button = smallButton(label, label.equals(currentMainTab));
        button.setOnClickListener(v -> {
            currentMainTab = label;
            if (label.equals("Trips")) {
                renderMainShell("My Trip", "ทริปส่วนตัวของคุณ", this::renderTripsContent);
            } else if (label.equals("Places")) {
                renderMainShell("Saved Places", "สถานที่ที่อยากไปทั้งหมด", this::renderAllPlacesContent);
            } else if (label.equals("Budget")) {
                renderMainShell("Budget", "สรุปงบประมาณทุกทริป", this::renderBudgetOverviewContent);
            } else if (label.equals("Checklist")) {
                renderMainShell("Checklist", "รายการเตรียมตัวทุกทริป", this::renderChecklistOverviewContent);
            } else {
                renderMainShell("Settings", "จัดการข้อมูลในเครื่อง", this::renderSettingsContent);
            }
        });
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(0, dp(46), 1);
        params.setMargins(dp(3), 0, dp(3), 0);
        nav.addView(button, params);
    }

    private void renderTripsContent(LinearLayout content) {
        Button create = primaryButton("+ สร้างทริปใหม่");
        create.setOnClickListener(v -> showCreateTripDialog());
        content.addView(create, new LinearLayout.LayoutParams(-1, dp(54)));
        content.addView(space(12));

        LinearLayout summary = card();
        summary.setBackground(gradient(SURFACE, SURFACE_WARM, dp(16)));
        summary.addView(text("ภาพรวมทริป", 18, TEXT, Typeface.BOLD));
        LinearLayout stats = new LinearLayout(this);
        stats.setOrientation(LinearLayout.HORIZONTAL);
        stats.setPadding(0, dp(10), 0, dp(8));
        stats.addView(metric("Planning", String.valueOf(countTrips("Planning")), PRIMARY), new LinearLayout.LayoutParams(0, -2, 1));
        stats.addView(metric("Traveling", String.valueOf(countTrips("Traveling")), SUCCESS), new LinearLayout.LayoutParams(0, -2, 1));
        stats.addView(metric("Completed", String.valueOf(countTrips("Completed")), MUTED), new LinearLayout.LayoutParams(0, -2, 1));
        summary.addView(stats);
        summary.addView(text("งบรวม " + baht(totalBudget()) + " • ใช้จริง " + baht(totalSpent(null)), 14, MUTED, Typeface.NORMAL));
        content.addView(summary);
        content.addView(space(16));

        if (trips.isEmpty()) {
            content.addView(emptyState("ยังไม่มีทริป", "เริ่มจากสร้างทริปแรก เช่น เชียงใหม่ 3 วัน 2 คืน"));
            return;
        }

        content.addView(sectionTitle("ทริปล่าสุด"));
        for (Trip trip : trips) {
            content.addView(tripCard(trip));
            content.addView(space(10));
        }
    }

    private LinearLayout tripCard(Trip trip) {
        LinearLayout card = card();
        card.setOnClickListener(v -> showTripDetail(trip.id));
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);

        TextView badge = text(statusIcon(trip.status), 24, Color.WHITE, Typeface.BOLD);
        badge.setGravity(Gravity.CENTER);
        badge.setBackground(rounded(statusColor(trip.status), dp(14)));
        LinearLayout.LayoutParams badgeParams = new LinearLayout.LayoutParams(dp(48), dp(48));
        badgeParams.setMargins(0, 0, dp(14), 0);
        row.addView(badge, badgeParams);

        LinearLayout detail = new LinearLayout(this);
        detail.setOrientation(LinearLayout.VERTICAL);
        detail.addView(text(trip.title, 21, TEXT, Typeface.BOLD));
        detail.addView(text(trip.location + " • " + displayDate(trip.startDate) + " - " + displayDate(trip.endDate), 14, MUTED, Typeface.NORMAL));
        TextView chip = text(trip.status + " • งบ " + baht(trip.budget), 13, statusColor(trip.status), Typeface.BOLD);
        chip.setPadding(0, dp(4), 0, 0);
        detail.addView(chip);
        row.addView(detail, new LinearLayout.LayoutParams(0, -2, 1));
        card.addView(row);
        return card;
    }

    private void showTripDetail(String tripId) {
        selectedTripId = tripId;
        Trip trip = getTrip(tripId);
        if (trip == null) {
            showHome();
            return;
        }

        root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(BACKGROUND);
        setContentView(root);
        applyInsets(root);

        LinearLayout header = new LinearLayout(this);
        header.setOrientation(LinearLayout.VERTICAL);
        header.setPadding(dp(16), dp(16), dp(16), dp(16));
        header.setBackground(gradient(PRIMARY, Color.rgb(255, 173, 61), 0));
        header.setElevation(dp(2));
        root.addView(header, new LinearLayout.LayoutParams(-1, -2));

        Button back = smallButton("‹ กลับ", true);
        back.setOnClickListener(v -> showHome());
        header.addView(back, new LinearLayout.LayoutParams(dp(104), dp(42)));
        header.addView(text(trip.title, 26, Color.WHITE, Typeface.BOLD));
        header.addView(text(trip.location + " • " + displayDate(trip.startDate) + " - " + displayDate(trip.endDate), 14, Color.WHITE, Typeface.NORMAL));

        HorizontalScrollView tabsScroll = new HorizontalScrollView(this);
        LinearLayout tabs = new LinearLayout(this);
        tabs.setOrientation(LinearLayout.HORIZONTAL);
        tabs.setPadding(dp(12), dp(10), dp(12), dp(10));
        tabsScroll.addView(tabs);
        root.addView(tabsScroll, new LinearLayout.LayoutParams(-1, -2));
        for (String tab : new String[]{"Plan", "Places", "Budget", "Checklist", "Memories"}) {
            Button button = smallButton(tab, tab.equals(currentDetailTab));
            button.setOnClickListener(v -> {
                currentDetailTab = tab;
                showTripDetail(tripId);
            });
            LinearLayout.LayoutParams tabParams = new LinearLayout.LayoutParams(dp(112), dp(42));
            tabParams.setMargins(dp(3), 0, dp(3), 0);
            tabs.addView(button, tabParams);
        }

        ScrollView scroll = new ScrollView(this);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(16), dp(14), dp(16), dp(20));
        scroll.addView(content);
        root.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1));

        if (currentDetailTab.equals("Plan")) renderPlanTab(content, trip);
        if (currentDetailTab.equals("Places")) renderPlacesTab(content, trip);
        if (currentDetailTab.equals("Budget")) renderBudgetTab(content, trip);
        if (currentDetailTab.equals("Checklist")) renderChecklistTab(content, trip);
        if (currentDetailTab.equals("Memories")) renderMemoriesTab(content, trip);
        keepScrollAtTop(scroll, content);
    }

    private void renderPlanTab(LinearLayout content, Trip trip) {
        Button add = primaryButton("+ เพิ่มกิจกรรมในแผนเที่ยว");
        add.setOnClickListener(v -> showPlanDialog(trip.id));
        content.addView(add, new LinearLayout.LayoutParams(-1, dp(52)));
        content.addView(space(12));

        List<PlanItem> items = planItems(trip.id);
        if (items.isEmpty()) {
            content.addView(emptyState("ยังไม่มีแผนรายวัน", "เพิ่มเวลาเดินทาง ร้านอาหาร ที่เที่ยว หรือโรงแรม"));
            return;
        }
        String lastDate = "";
        for (PlanItem item : items) {
            String date = displayDate(item.date);
            if (!date.equals(lastDate)) {
                content.addView(sectionTitle(date));
                lastDate = date;
            }
            LinearLayout card = card();
            CheckBox done = new CheckBox(this);
            done.setText(item.time + " - " + item.title);
            done.setTextColor(TEXT);
            done.setTextSize(16);
            done.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
            done.setChecked(item.done);
            done.setOnCheckedChangeListener((buttonView, isChecked) -> {
                item.done = isChecked;
                saveData();
            });
            card.addView(done);
            card.addView(text(item.category + " • ประมาณ " + baht(item.estimatedCost), 14, MUTED, Typeface.NORMAL));
            if (!item.note.isEmpty()) card.addView(text(item.note, 14, MUTED, Typeface.NORMAL));
            content.addView(card);
            content.addView(space(8));
        }
    }

    private void renderPlacesTab(LinearLayout content, Trip trip) {
        Button add = primaryButton("+ เพิ่มสถานที่ที่อยากไป");
        add.setOnClickListener(v -> showPlaceDialog(trip.id));
        content.addView(add, new LinearLayout.LayoutParams(-1, dp(52)));
        content.addView(space(12));

        List<Place> items = placesForTrip(trip.id);
        if (items.isEmpty()) {
            content.addView(emptyState("ยังไม่มีสถานที่", "เก็บคาเฟ่ ร้านอาหาร จุดถ่ายรูป หรือโรงแรมไว้ก่อนจัดแผน"));
            return;
        }
        for (Place place : items) content.addView(placeCard(place));
    }

    private void renderBudgetTab(LinearLayout content, Trip trip) {
        Button add = primaryButton("+ เพิ่มค่าใช้จ่าย");
        add.setOnClickListener(v -> showExpenseDialog(trip.id));
        content.addView(add, new LinearLayout.LayoutParams(-1, dp(52)));
        content.addView(space(12));

        double spent = totalSpent(trip.id);
        LinearLayout summary = card();
        summary.addView(text("งบทริปทั้งหมด: " + baht(trip.budget), 18, TEXT, Typeface.BOLD));
        summary.addView(text("ใช้ไปแล้ว: " + baht(spent), 16, DANGER, Typeface.BOLD));
        summary.addView(text("คงเหลือ: " + baht(trip.budget - spent), 16, SUCCESS, Typeface.BOLD));
        content.addView(summary);
        content.addView(space(12));

        List<ExpenseItem> items = expensesForTrip(trip.id);
        if (items.isEmpty()) {
            content.addView(emptyState("ยังไม่มีค่าใช้จ่าย", "เพิ่มค่ารถ ที่พัก อาหาร ค่าเข้าชม หรือช้อปปิ้ง"));
            return;
        }
        for (ExpenseItem expense : items) {
            LinearLayout card = card();
            card.addView(text(expense.title + " • " + baht(expense.amount), 17, TEXT, Typeface.BOLD));
            card.addView(text(expense.category + " • " + displayDate(expense.date), 14, MUTED, Typeface.NORMAL));
            if (!expense.note.isEmpty()) card.addView(text(expense.note, 14, MUTED, Typeface.NORMAL));
            content.addView(card);
            content.addView(space(8));
        }
    }

    private void renderChecklistTab(LinearLayout content, Trip trip) {
        Button add = primaryButton("+ เพิ่มรายการเตรียมของ");
        add.setOnClickListener(v -> showChecklistDialog(trip.id));
        content.addView(add, new LinearLayout.LayoutParams(-1, dp(52)));
        content.addView(space(12));

        List<ChecklistItem> items = checklistForTrip(trip.id);
        if (items.isEmpty()) {
            String[] defaults = {"บัตรประชาชน", "พาสปอร์ต", "เสื้อผ้า", "ยาประจำตัว", "ที่ชาร์จ", "พาวเวอร์แบงก์", "เงินสด", "ใบจองโรงแรม"};
            for (String title : defaults) checklist.add(new ChecklistItem(id(), trip.id, title, false));
            saveData();
            items = checklistForTrip(trip.id);
        }
        for (ChecklistItem item : items) {
            CheckBox box = new CheckBox(this);
            box.setText(item.title);
            box.setTextSize(16);
            box.setTextColor(TEXT);
            box.setChecked(item.checked);
            box.setPadding(dp(12), dp(8), dp(12), dp(8));
            box.setBackground(strokeBackground(SURFACE, BORDER, 1, dp(14)));
            box.setElevation(dp(1));
            box.setOnCheckedChangeListener((buttonView, isChecked) -> {
                item.checked = isChecked;
                saveData();
            });
            content.addView(box, new LinearLayout.LayoutParams(-1, dp(52)));
            content.addView(space(6));
        }
    }

    private void renderMemoriesTab(LinearLayout content, Trip trip) {
        Button add = primaryButton("+ บันทึกความทรงจำ");
        add.setOnClickListener(v -> showMemoryDialog(trip.id));
        content.addView(add, new LinearLayout.LayoutParams(-1, dp(52)));
        content.addView(space(12));

        List<MemoryItem> items = memoriesForTrip(trip.id);
        if (items.isEmpty()) {
            content.addView(emptyState("ยังไม่มีบันทึก", "ระหว่างเที่ยวหรือหลังเที่ยว เพิ่มรูป โน้ต และคะแนนความประทับใจ"));
            return;
        }
        for (MemoryItem memory : items) {
            LinearLayout card = card();
            card.addView(text(displayDate(memory.date) + " • คะแนน " + memory.rating + "/5", 17, TEXT, Typeface.BOLD));
            card.addView(text(memory.note, 15, MUTED, Typeface.NORMAL));
            content.addView(card);
            content.addView(space(8));
        }
    }

    private LinearLayout placeCard(Place place) {
        LinearLayout card = card();
        CheckBox visited = new CheckBox(this);
        visited.setText(place.name);
        visited.setTextColor(TEXT);
        visited.setTextSize(17);
        visited.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        visited.setChecked(place.visited);
        visited.setOnCheckedChangeListener((buttonView, isChecked) -> {
            place.visited = isChecked;
            saveData();
        });
        card.addView(visited);
        card.addView(text(place.category + " • " + statusPlace(place), 14, place.visited ? SUCCESS : MUTED, Typeface.BOLD));
        if (!place.address.isEmpty()) card.addView(text(place.address, 14, MUTED, Typeface.NORMAL));
        if (!place.note.isEmpty()) card.addView(text(place.note, 14, MUTED, Typeface.NORMAL));
        return card;
    }

    private void renderAllPlacesContent(LinearLayout content) {
        if (places.isEmpty()) {
            content.addView(emptyState("ยังไม่มี Saved Places", "เข้าไปใน Trip Detail แล้วเพิ่มสถานที่ที่อยากไป"));
            return;
        }
        for (Place place : places) {
            Trip trip = getTrip(place.tripId);
            content.addView(sectionTitle(trip == null ? "ไม่พบทริป" : trip.title));
            content.addView(placeCard(place));
            content.addView(space(10));
        }
    }

    private void renderBudgetOverviewContent(LinearLayout content) {
        LinearLayout summary = card();
        summary.addView(text("งบรวมทั้งหมด " + baht(totalBudget()), 18, TEXT, Typeface.BOLD));
        summary.addView(text("ใช้จริงรวม " + baht(totalSpent(null)), 16, DANGER, Typeface.BOLD));
        summary.addView(text("คงเหลือรวม " + baht(totalBudget() - totalSpent(null)), 16, SUCCESS, Typeface.BOLD));
        content.addView(summary);
        content.addView(space(12));
        for (Trip trip : trips) {
            LinearLayout card = card();
            double spent = totalSpent(trip.id);
            card.addView(text(trip.title, 17, TEXT, Typeface.BOLD));
            card.addView(text("งบ " + baht(trip.budget) + " • ใช้แล้ว " + baht(spent) + " • เหลือ " + baht(trip.budget - spent), 14, MUTED, Typeface.NORMAL));
            card.setOnClickListener(v -> {
                currentDetailTab = "Budget";
                showTripDetail(trip.id);
            });
            content.addView(card);
            content.addView(space(8));
        }
    }

    private void renderChecklistOverviewContent(LinearLayout content) {
        if (checklist.isEmpty()) {
            content.addView(emptyState("ยังไม่มี Checklist", "เข้า Trip Detail เพื่อเริ่มรายการเตรียมตัว"));
            return;
        }
        for (Trip trip : trips) {
            int total = checklistForTrip(trip.id).size();
            if (total == 0) continue;
            int done = 0;
            for (ChecklistItem item : checklistForTrip(trip.id)) if (item.checked) done++;
            LinearLayout card = card();
            card.addView(text(trip.title, 17, TEXT, Typeface.BOLD));
            card.addView(text("เตรียมแล้ว " + done + "/" + total + " รายการ", 14, MUTED, Typeface.NORMAL));
            card.setOnClickListener(v -> {
                currentDetailTab = "Checklist";
                showTripDetail(trip.id);
            });
            content.addView(card);
            content.addView(space(8));
        }
    }

    private void renderSettingsContent(LinearLayout content) {
        content.addView(sectionTitle("ข้อมูลในเครื่อง"));
        content.addView(text("แอปนี้เก็บข้อมูลทั้งหมดไว้ในเครื่องด้วย SharedPreferences ไม่ต้อง Login หรือ Cloud sync ใน MVP", 15, MUTED, Typeface.NORMAL));
        content.addView(space(12));
        Button seed = primaryButton("เติมข้อมูลตัวอย่าง");
        seed.setOnClickListener(v -> {
            seedData();
            saveData();
            Toast.makeText(this, "เพิ่มข้อมูลตัวอย่างแล้ว", Toast.LENGTH_SHORT).show();
            showHome();
        });
        content.addView(seed, new LinearLayout.LayoutParams(-1, dp(52)));
        content.addView(space(10));
        Button clear = outlineButton("ล้างข้อมูลทั้งหมด");
        clear.setTextColor(DANGER);
        clear.setOnClickListener(v -> new AlertDialog.Builder(this)
                .setTitle("ล้างข้อมูลทั้งหมด?")
                .setMessage("ทริป แผน สถานที่ งบ Checklist และ Memories จะถูกลบจากเครื่อง")
                .setNegativeButton("ยกเลิก", null)
                .setPositiveButton("ล้างข้อมูล", (dialog, which) -> {
                    trips.clear(); plans.clear(); places.clear(); expenses.clear(); checklist.clear(); memories.clear(); saveData(); showHome();
                }).show());
        content.addView(clear, new LinearLayout.LayoutParams(-1, dp(52)));
    }

    private void showCreateTripDialog() {
        LinearLayout form = form();
        EditText title = input("ชื่อทริป เช่น เชียงใหม่ 3 วัน 2 คืน");
        EditText location = input("จังหวัด/ประเทศ");
        EditText start = dateInput("วันที่เริ่มต้น yyyy-MM-dd");
        EditText end = dateInput("วันที่สิ้นสุด yyyy-MM-dd");
        EditText budget = numberInput("งบประมาณ");
        Spinner status = spinner(new String[]{"Planning", "Traveling", "Completed"});
        form.addView(title); form.addView(location); form.addView(start); form.addView(end); form.addView(budget); form.addView(status);
        new AlertDialog.Builder(this)
                .setTitle("สร้างทริปใหม่")
                .setView(form)
                .setNegativeButton("ยกเลิก", null)
                .setPositiveButton("บันทึก", (dialog, which) -> {
                    Date startDate = parseDateOrToday(start.getText().toString());
                    Date endDate = parseDateOrToday(end.getText().toString());
                    trips.add(0, new Trip(id(), value(title, "ทริปใหม่"), value(location, "ยังไม่ระบุ"), startDate, endDate, parseDouble(budget), status.getSelectedItem().toString()));
                    saveData();
                    showHome();
                }).show();
    }

    private void showPlanDialog(String tripId) {
        LinearLayout form = form();
        EditText date = dateInput("วันที่ yyyy-MM-dd");
        EditText time = input("เวลา เช่น 09:00");
        EditText title = input("ชื่อกิจกรรมหรือสถานที่");
        Spinner category = spinner(new String[]{"เดินทาง", "ร้านอาหาร", "ที่เที่ยว", "โรงแรม", "คาเฟ่", "อื่น ๆ"});
        EditText note = input("หมายเหตุ");
        EditText cost = numberInput("ค่าใช้จ่ายโดยประมาณ");
        form.addView(date); form.addView(time); form.addView(title); form.addView(category); form.addView(note); form.addView(cost);
        new AlertDialog.Builder(this).setTitle("เพิ่มแผนเที่ยว")
                .setView(form).setNegativeButton("ยกเลิก", null).setPositiveButton("บันทึก", (d, w) -> {
                    plans.add(new PlanItem(id(), tripId, parseDateOrToday(date.getText().toString()), value(time, "09:00"), value(title, "กิจกรรมใหม่"), category.getSelectedItem().toString(), note.getText().toString(), parseDouble(cost), false));
                    saveData(); showTripDetail(tripId);
                }).show();
    }

    private void showPlaceDialog(String tripId) {
        LinearLayout form = form();
        EditText name = input("ชื่อสถานที่");
        Spinner category = spinner(new String[]{"ที่เที่ยว", "ร้านอาหาร", "คาเฟ่", "โรงแรม", "จุดถ่ายรูป", "การเดินทาง", "อื่น ๆ"});
        EditText address = input("ที่อยู่");
        EditText note = input("หมายเหตุ");
        form.addView(name); form.addView(category); form.addView(address); form.addView(note);
        new AlertDialog.Builder(this).setTitle("เพิ่มสถานที่")
                .setView(form).setNegativeButton("ยกเลิก", null).setPositiveButton("บันทึก", (d, w) -> {
                    places.add(new Place(id(), tripId, value(name, "สถานที่ใหม่"), category.getSelectedItem().toString(), address.getText().toString(), note.getText().toString(), false));
                    saveData(); showTripDetail(tripId);
                }).show();
    }

    private void showExpenseDialog(String tripId) {
        LinearLayout form = form();
        EditText title = input("ชื่อรายการ");
        EditText amount = numberInput("จำนวนเงิน");
        Spinner category = spinner(new String[]{"ค่าเดินทาง", "ที่พัก", "อาหาร", "ค่าเข้าชม", "ช้อปปิ้ง", "อื่น ๆ"});
        EditText date = dateInput("วันที่ yyyy-MM-dd");
        EditText note = input("หมายเหตุ");
        form.addView(title); form.addView(amount); form.addView(category); form.addView(date); form.addView(note);
        new AlertDialog.Builder(this).setTitle("เพิ่มค่าใช้จ่าย")
                .setView(form).setNegativeButton("ยกเลิก", null).setPositiveButton("บันทึก", (d, w) -> {
                    expenses.add(new ExpenseItem(id(), tripId, value(title, "ค่าใช้จ่าย"), parseDouble(amount), category.getSelectedItem().toString(), parseDateOrToday(date.getText().toString()), note.getText().toString()));
                    saveData(); showTripDetail(tripId);
                }).show();
    }

    private void showChecklistDialog(String tripId) {
        EditText title = input("รายการที่ต้องเตรียม");
        new AlertDialog.Builder(this).setTitle("เพิ่ม Checklist")
                .setView(title).setNegativeButton("ยกเลิก", null).setPositiveButton("บันทึก", (d, w) -> {
                    checklist.add(new ChecklistItem(id(), tripId, value(title, "รายการใหม่"), false));
                    saveData(); showTripDetail(tripId);
                }).show();
    }

    private void showMemoryDialog(String tripId) {
        LinearLayout form = form();
        EditText date = dateInput("วันที่ yyyy-MM-dd");
        EditText note = input("ข้อความบันทึก");
        EditText rating = numberInput("คะแนน 1-5");
        form.addView(date); form.addView(note); form.addView(rating);
        new AlertDialog.Builder(this).setTitle("บันทึกความทรงจำ")
                .setView(form).setNegativeButton("ยกเลิก", null).setPositiveButton("บันทึก", (d, w) -> {
                    int score = Math.max(1, Math.min(5, (int) parseDouble(rating)));
                    memories.add(new MemoryItem(id(), tripId, parseDateOrToday(date.getText().toString()), value(note, "วันนี้เป็นวันที่ดีมาก"), score));
                    saveData(); showTripDetail(tripId);
                }).show();
    }

    private void loadData() {
        String raw = getSharedPreferences(PREFS, MODE_PRIVATE).getString(KEY_DATA, null);
        if (raw == null) {
            seedData();
            saveData();
            return;
        }
        try {
            JSONObject json = new JSONObject(raw);
            JSONArray tripArray = json.optJSONArray("trips");
            if (tripArray != null) for (int i = 0; i < tripArray.length(); i++) trips.add(Trip.fromJson(tripArray.getJSONObject(i), this));
            JSONArray planArray = json.optJSONArray("plans");
            if (planArray != null) for (int i = 0; i < planArray.length(); i++) plans.add(PlanItem.fromJson(planArray.getJSONObject(i), this));
            JSONArray placeArray = json.optJSONArray("places");
            if (placeArray != null) for (int i = 0; i < placeArray.length(); i++) places.add(Place.fromJson(placeArray.getJSONObject(i)));
            JSONArray expenseArray = json.optJSONArray("expenses");
            if (expenseArray != null) for (int i = 0; i < expenseArray.length(); i++) expenses.add(ExpenseItem.fromJson(expenseArray.getJSONObject(i), this));
            JSONArray checklistArray = json.optJSONArray("checklist");
            if (checklistArray != null) for (int i = 0; i < checklistArray.length(); i++) checklist.add(ChecklistItem.fromJson(checklistArray.getJSONObject(i)));
            JSONArray memoryArray = json.optJSONArray("memories");
            if (memoryArray != null) for (int i = 0; i < memoryArray.length(); i++) memories.add(MemoryItem.fromJson(memoryArray.getJSONObject(i), this));
        } catch (JSONException e) {
            seedData();
            saveData();
        }
    }

    private void saveData() {
        try {
            JSONObject json = new JSONObject();
            JSONArray tripArray = new JSONArray();
            for (Trip trip : trips) tripArray.put(trip.toJson(this));
            JSONArray planArray = new JSONArray();
            for (PlanItem plan : plans) planArray.put(plan.toJson(this));
            JSONArray placeArray = new JSONArray();
            for (Place place : places) placeArray.put(place.toJson());
            JSONArray expenseArray = new JSONArray();
            for (ExpenseItem expense : expenses) expenseArray.put(expense.toJson(this));
            JSONArray checklistArray = new JSONArray();
            for (ChecklistItem item : checklist) checklistArray.put(item.toJson());
            JSONArray memoryArray = new JSONArray();
            for (MemoryItem memory : memories) memoryArray.put(memory.toJson(this));
            json.put("trips", tripArray); json.put("plans", planArray); json.put("places", placeArray); json.put("expenses", expenseArray); json.put("checklist", checklistArray); json.put("memories", memoryArray);
            getSharedPreferences(PREFS, MODE_PRIVATE).edit().putString(KEY_DATA, json.toString()).apply();
        } catch (JSONException ignored) {
        }
    }

    private void seedData() {
        trips.clear(); plans.clear(); places.clear(); expenses.clear(); checklist.clear(); memories.clear();
        String tripId = id();
        trips.add(new Trip(tripId, "เชียงใหม่ 3 วัน 2 คืน", "เชียงใหม่, ประเทศไทย", parseDateOrToday("2026-12-12"), parseDateOrToday("2026-12-14"), 5000, "Planning"));
        plans.add(new PlanItem(id(), tripId, parseDateOrToday("2026-12-12"), "09:00", "เดินทางไปสนามบิน", "เดินทาง", "เผื่อเวลาเช็กอิน", 350, false));
        plans.add(new PlanItem(id(), tripId, parseDateOrToday("2026-12-12"), "13:00", "กินข้าวร้านอาหารพื้นเมือง", "ร้านอาหาร", "ลองข้าวซอย", 250, false));
        plans.add(new PlanItem(id(), tripId, parseDateOrToday("2026-12-12"), "18:00", "เดินตลาดกลางคืน", "ที่เที่ยว", "ซื้อของฝาก", 500, false));
        places.add(new Place(id(), tripId, "วัดพระธาตุดอยสุเทพ", "ที่เที่ยว", "อำเภอเมืองเชียงใหม่", "ไปช่วงเช้า อากาศดี", false));
        places.add(new Place(id(), tripId, "คาเฟ่นิมมาน", "คาเฟ่", "ถนนนิมมานเหมินท์", "ถ่ายรูปและพักช่วงบ่าย", false));
        expenses.add(new ExpenseItem(id(), tripId, "ตั๋วเครื่องบิน", 1800, "ค่าเดินทาง", parseDateOrToday("2026-12-12"), "ไป-กลับ"));
        expenses.add(new ExpenseItem(id(), tripId, "มัดจำโรงแรม", 550, "ที่พัก", parseDateOrToday("2026-12-12"), "คืนแรก"));
        checklist.add(new ChecklistItem(id(), tripId, "บัตรประชาชน", true));
        checklist.add(new ChecklistItem(id(), tripId, "เสื้อผ้า", false));
        checklist.add(new ChecklistItem(id(), tripId, "ที่ชาร์จ", false));
        memories.add(new MemoryItem(id(), tripId, parseDateOrToday("2026-12-12"), "วันนี้ไปดอยสุเทพ อากาศดีมาก วิวสวย คนไม่เยอะ", 5));
    }

    private LinearLayout card() {
        LinearLayout view = new LinearLayout(this);
        view.setOrientation(LinearLayout.VERTICAL);
        view.setPadding(dp(16), dp(15), dp(16), dp(15));
        view.setBackground(strokeBackground(SURFACE, Color.rgb(250, 225, 195), 1, dp(16)));
        view.setElevation(dp(3));
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(-1, -2);
        params.setMargins(0, dp(2), 0, dp(8));
        view.setLayoutParams(params);
        return view;
    }

    private LinearLayout metric(String label, String value, int color) {
        LinearLayout box = new LinearLayout(this);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setGravity(Gravity.CENTER);
        box.setPadding(dp(6), dp(8), dp(6), dp(8));
        box.setBackground(strokeBackground(Color.rgb(255, 250, 244), Color.argb(70, Color.red(color), Color.green(color), Color.blue(color)), 1, dp(14)));
        TextView number = text(value, 21, color, Typeface.BOLD);
        number.setGravity(Gravity.CENTER);
        TextView caption = text(label, 11, MUTED, Typeface.NORMAL);
        caption.setGravity(Gravity.CENTER);
        box.addView(number);
        box.addView(caption);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(-1, -2);
        params.setMargins(dp(3), 0, dp(3), 0);
        box.setLayoutParams(params);
        return box;
    }

    private TextView emptyState(String title, String message) {
        TextView view = text(title + "\n" + message, 16, MUTED, Typeface.NORMAL);
        view.setGravity(Gravity.CENTER);
        view.setPadding(dp(20), dp(34), dp(20), dp(34));
        view.setBackground(strokeBackground(SURFACE, BORDER, 1, dp(18)));
        view.setElevation(dp(2));
        return view;
    }

    private TextView sectionTitle(String title) {
        TextView view = text(title, 18, TEXT, Typeface.BOLD);
        view.setPadding(dp(2), dp(12), 0, dp(10));
        return view;
    }

    private TextView text(String value, int sp, int color, int style) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextSize(sp);
        view.setTextColor(color);
        view.setTypeface(Typeface.DEFAULT, style);
        view.setLineSpacing(dp(2), 1.08f);
        return view;
    }

    private Button primaryButton(String label) {
        Button button = new Button(this);
        button.setText(label);
        button.setAllCaps(false);
        button.setTextColor(Color.WHITE);
        button.setTextSize(15);
        button.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        button.setPadding(dp(14), 0, dp(14), 0);
        button.setBackground(gradient(PRIMARY, Color.rgb(255, 168, 45), dp(16)));
        button.setElevation(dp(3));
        return button;
    }

    private Button outlineButton(String label) {
        Button button = new Button(this);
        button.setText(label);
        button.setAllCaps(false);
        button.setTextColor(PRIMARY);
        button.setTextSize(15);
        button.setTypeface(Typeface.DEFAULT, Typeface.BOLD);
        button.setPadding(dp(14), 0, dp(14), 0);
        button.setBackground(strokeBackground(SURFACE, BORDER, 1, dp(16)));
        return button;
    }

    private Button smallButton(String label, boolean active) {
        Button button = new Button(this);
        button.setText(label);
        button.setAllCaps(false);
        button.setTextSize(12);
        button.setTypeface(Typeface.DEFAULT, active ? Typeface.BOLD : Typeface.NORMAL);
        button.setTextColor(active ? Color.WHITE : MUTED);
        button.setPadding(dp(8), 0, dp(8), 0);
        button.setBackground(active ? rounded(PRIMARY, dp(14)) : rounded(Color.TRANSPARENT, dp(14)));
        return button;
    }

    private GradientDrawable rounded(int color, int radius) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setColor(color);
        drawable.setCornerRadius(radius);
        return drawable;
    }

    private GradientDrawable strokeBackground(int color, int strokeColor, int strokeDp, int radius) {
        GradientDrawable drawable = rounded(color, radius);
        drawable.setStroke(dp(strokeDp), strokeColor);
        return drawable;
    }

    private GradientDrawable gradient(int startColor, int endColor, int radius) {
        GradientDrawable drawable = new GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT, new int[]{startColor, endColor});
        drawable.setCornerRadius(radius);
        return drawable;
    }

    private LinearLayout form() {
        LinearLayout form = new LinearLayout(this);
        form.setOrientation(LinearLayout.VERTICAL);
        form.setPadding(dp(8), dp(8), dp(8), 0);
        return form;
    }

    private EditText input(String hint) {
        EditText edit = new EditText(this);
        edit.setHint(hint);
        edit.setSingleLine(false);
        edit.setImeOptions(EditorInfo.IME_ACTION_NEXT);
        edit.setTextColor(TEXT);
        edit.setHintTextColor(MUTED);
        return edit;
    }

    private EditText numberInput(String hint) {
        EditText edit = input(hint);
        edit.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
        return edit;
    }

    private EditText dateInput(String hint) {
        EditText edit = input(hint);
        edit.setSingleLine(true);
        edit.setInputType(InputType.TYPE_CLASS_DATETIME);
        edit.setText(storageDate.format(new Date()));
        edit.setOnClickListener(v -> {
            Calendar calendar = Calendar.getInstance();
            new DatePickerDialog(this, (view, year, month, dayOfMonth) -> {
                Calendar chosen = Calendar.getInstance();
                chosen.set(year, month, dayOfMonth);
                edit.setText(storageDate.format(chosen.getTime()));
            }, calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH)).show();
        });
        return edit;
    }

    private Spinner spinner(String[] values) {
        Spinner spinner = new Spinner(this);
        spinner.setAdapter(new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, values));
        return spinner;
    }

    private Space space(int dp) {
        Space space = new Space(this);
        space.setLayoutParams(new LinearLayout.LayoutParams(1, dp(dp)));
        return space;
    }

    private void keepScrollAtTop(ScrollView scroll, LinearLayout content) {
        scroll.setDescendantFocusability(ViewGroup.FOCUS_BEFORE_DESCENDANTS);
        scroll.setFocusableInTouchMode(true);
        content.setFocusableInTouchMode(true);
        content.requestFocus();
        scroll.post(() -> scroll.scrollTo(0, 0));
    }

    private void applyInsets(View view) {
        ViewCompat.setOnApplyWindowInsetsListener(view, (v, insets) -> {
            android.graphics.Insets bars = insets.getInsets(WindowInsetsCompat.Type.systemBars()).toPlatformInsets();
            v.setPadding(v.getPaddingLeft() + bars.left, v.getPaddingTop() + bars.top, v.getPaddingRight() + bars.right, v.getPaddingBottom() + bars.bottom);
            return insets;
        });
    }

    private int dp(int value) {
        return (int) (value * getResources().getDisplayMetrics().density + 0.5f);
    }

    private String id() { return UUID.randomUUID().toString(); }
    private String value(EditText edit, String fallback) { String text = edit.getText().toString().trim(); return text.isEmpty() ? fallback : text; }
    private double parseDouble(EditText edit) { return parseDouble(edit.getText().toString()); }
    private double parseDouble(String value) { try { return Double.parseDouble(value.trim()); } catch (Exception e) { return 0; } }
    private Date parseDateOrToday(String value) { try { return storageDate.parse(value.trim()); } catch (ParseException e) { return new Date(); } }
    private String displayDate(Date date) { return displayDate.format(date); }
    private String storageDate(Date date) { return storageDate.format(date); }
    private String baht(double amount) { return money.format(amount) + " บาท"; }

    private int countTrips(String status) { int count = 0; for (Trip trip : trips) if (trip.status.equals(status)) count++; return count; }
    private double totalBudget() { double sum = 0; for (Trip trip : trips) sum += trip.budget; return sum; }
    private double totalSpent(String tripId) { double sum = 0; for (ExpenseItem expense : expenses) if (tripId == null || expense.tripId.equals(tripId)) sum += expense.amount; return sum; }
    private Trip getTrip(String id) { for (Trip trip : trips) if (trip.id.equals(id)) return trip; return null; }
    private int statusColor(String status) { if (status.equals("Traveling")) return SUCCESS; if (status.equals("Completed")) return MUTED; return PRIMARY; }
    private String statusIcon(String status) { if (status.equals("Traveling")) return "▶"; if (status.equals("Completed")) return "✓"; return "＋"; }
    private String statusPlace(Place place) { return place.visited ? "ไปแล้ว" : "อยากไป"; }

    private List<PlanItem> planItems(String tripId) { List<PlanItem> list = new ArrayList<>(); for (PlanItem item : plans) if (item.tripId.equals(tripId)) list.add(item); return list; }
    private List<Place> placesForTrip(String tripId) { List<Place> list = new ArrayList<>(); for (Place item : places) if (item.tripId.equals(tripId)) list.add(item); return list; }
    private List<ExpenseItem> expensesForTrip(String tripId) { List<ExpenseItem> list = new ArrayList<>(); for (ExpenseItem item : expenses) if (item.tripId.equals(tripId)) list.add(item); return list; }
    private List<ChecklistItem> checklistForTrip(String tripId) { List<ChecklistItem> list = new ArrayList<>(); for (ChecklistItem item : checklist) if (item.tripId.equals(tripId)) list.add(item); return list; }
    private List<MemoryItem> memoriesForTrip(String tripId) { List<MemoryItem> list = new ArrayList<>(); for (MemoryItem item : memories) if (item.tripId.equals(tripId)) list.add(item); return list; }

    interface ContentRenderer { void render(LinearLayout content); }

    static class Trip {
        String id, title, location, status;
        Date startDate, endDate;
        double budget;
        Trip(String id, String title, String location, Date startDate, Date endDate, double budget, String status) { this.id = id; this.title = title; this.location = location; this.startDate = startDate; this.endDate = endDate; this.budget = budget; this.status = status; }
        JSONObject toJson(MainActivity a) throws JSONException { return new JSONObject().put("id", id).put("title", title).put("location", location).put("startDate", a.storageDate(startDate)).put("endDate", a.storageDate(endDate)).put("budget", budget).put("status", status); }
        static Trip fromJson(JSONObject j, MainActivity a) { return new Trip(j.optString("id"), j.optString("title"), j.optString("location"), a.parseDateOrToday(j.optString("startDate")), a.parseDateOrToday(j.optString("endDate")), j.optDouble("budget"), j.optString("status", "Planning")); }
    }

    static class PlanItem {
        String id, tripId, time, title, category, note;
        Date date;
        double estimatedCost;
        boolean done;
        PlanItem(String id, String tripId, Date date, String time, String title, String category, String note, double estimatedCost, boolean done) { this.id = id; this.tripId = tripId; this.date = date; this.time = time; this.title = title; this.category = category; this.note = note; this.estimatedCost = estimatedCost; this.done = done; }
        JSONObject toJson(MainActivity a) throws JSONException { return new JSONObject().put("id", id).put("tripId", tripId).put("date", a.storageDate(date)).put("time", time).put("title", title).put("category", category).put("note", note).put("estimatedCost", estimatedCost).put("done", done); }
        static PlanItem fromJson(JSONObject j, MainActivity a) { return new PlanItem(j.optString("id"), j.optString("tripId"), a.parseDateOrToday(j.optString("date")), j.optString("time"), j.optString("title"), j.optString("category"), j.optString("note"), j.optDouble("estimatedCost"), j.optBoolean("done")); }
    }

    static class Place {
        String id, tripId, name, category, address, note;
        boolean visited;
        Place(String id, String tripId, String name, String category, String address, String note, boolean visited) { this.id = id; this.tripId = tripId; this.name = name; this.category = category; this.address = address; this.note = note; this.visited = visited; }
        JSONObject toJson() throws JSONException { return new JSONObject().put("id", id).put("tripId", tripId).put("name", name).put("category", category).put("address", address).put("note", note).put("visited", visited); }
        static Place fromJson(JSONObject j) { return new Place(j.optString("id"), j.optString("tripId"), j.optString("name"), j.optString("category"), j.optString("address"), j.optString("note"), j.optBoolean("visited")); }
    }

    static class ExpenseItem {
        String id, tripId, title, category, note;
        double amount;
        Date date;
        ExpenseItem(String id, String tripId, String title, double amount, String category, Date date, String note) { this.id = id; this.tripId = tripId; this.title = title; this.amount = amount; this.category = category; this.date = date; this.note = note; }
        JSONObject toJson(MainActivity a) throws JSONException { return new JSONObject().put("id", id).put("tripId", tripId).put("title", title).put("amount", amount).put("category", category).put("date", a.storageDate(date)).put("note", note); }
        static ExpenseItem fromJson(JSONObject j, MainActivity a) { return new ExpenseItem(j.optString("id"), j.optString("tripId"), j.optString("title"), j.optDouble("amount"), j.optString("category"), a.parseDateOrToday(j.optString("date")), j.optString("note")); }
    }

    static class ChecklistItem {
        String id, tripId, title;
        boolean checked;
        ChecklistItem(String id, String tripId, String title, boolean checked) { this.id = id; this.tripId = tripId; this.title = title; this.checked = checked; }
        JSONObject toJson() throws JSONException { return new JSONObject().put("id", id).put("tripId", tripId).put("title", title).put("checked", checked); }
        static ChecklistItem fromJson(JSONObject j) { return new ChecklistItem(j.optString("id"), j.optString("tripId"), j.optString("title"), j.optBoolean("checked")); }
    }

    static class MemoryItem {
        String id, tripId, note;
        Date date;
        int rating;
        MemoryItem(String id, String tripId, Date date, String note, int rating) { this.id = id; this.tripId = tripId; this.date = date; this.note = note; this.rating = rating; }
        JSONObject toJson(MainActivity a) throws JSONException { return new JSONObject().put("id", id).put("tripId", tripId).put("date", a.storageDate(date)).put("note", note).put("rating", rating); }
        static MemoryItem fromJson(JSONObject j, MainActivity a) { return new MemoryItem(j.optString("id"), j.optString("tripId"), a.parseDateOrToday(j.optString("date")), j.optString("note"), j.optInt("rating", 5)); }
    }
}
