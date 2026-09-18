#include "QGCPalette.h"
#include "QGCCorePlugin.h"

#include <QtCore/QDebug>

QList<QGCPalette*>   QGCPalette::_paletteObjects;

QGCPalette::Theme QGCPalette::_theme = QGCPalette::Dark;

QMap<int, QMap<int, QMap<QString, QColor>>> QGCPalette::_colorInfoMap;

QStringList QGCPalette::_colors;

QGCPalette::QGCPalette(QObject* parent) :
    QObject(parent),
    _colorGroupEnabled(true)
{
    if (_colorInfoMap.isEmpty()) {
        _buildMap();
    }

    // We have to keep track of all QGCPalette objects in the system so we can signal theme change to all of them
    _paletteObjects += this;
}

QGCPalette::~QGCPalette()
{
    bool fSuccess = _paletteObjects.removeOne(this);
    if (!fSuccess) {
        qWarning() << "Internal error";
    }
}

void QGCPalette::_buildMap()
{
    // CDA sky-blue-and-white theme: the same values are used in the Light and Dark
    // slots so the app looks the same whether "indoor palette" (Dark) is on or off.
    //                                      Light                 Dark
    //                                      Disabled   Enabled    Disabled   Enabled
    DECLARE_QGC_COLOR(window,               "#ffffff", "#ffffff", "#ffffff", "#ffffff")
    DECLARE_QGC_COLOR(windowTransparent,    "#ccffffff", "#ccffffff", "#ccffffff", "#ccffffff")
    DECLARE_QGC_COLOR(windowShadeLight,     "#cdeaf9", "#7fcdf2", "#cdeaf9", "#7fcdf2")
    DECLARE_QGC_COLOR(windowShade,          "#e3f6fd", "#e3f6fd", "#e3f6fd", "#e3f6fd")
    DECLARE_QGC_COLOR(windowShadeDark,      "#c7ecfa", "#c7ecfa", "#c7ecfa", "#c7ecfa")
    DECLARE_QGC_COLOR(text,                 "#8aa6b8", "#0f2c42", "#8aa6b8", "#0f2c42")
    DECLARE_QGC_COLOR(warningText,          "#cc0808", "#cc0808", "#cc0808", "#cc0808")
    DECLARE_QGC_COLOR(button,               "#ffffff", "#ffffff", "#ffffff", "#ffffff")
    DECLARE_QGC_COLOR(buttonBorder,         "#9edcf5", "#0ea5e9", "#9edcf5", "#0ea5e9")
    DECLARE_QGC_COLOR(buttonText,           "#8aa6b8", "#0f2c42", "#8aa6b8", "#0f2c42")
    DECLARE_QGC_COLOR(buttonHighlight,      "#9edcf5", "#0ea5e9", "#9edcf5", "#0ea5e9")
    DECLARE_QGC_COLOR(buttonHighlightText,  "#ffffff", "#ffffff", "#ffffff", "#ffffff")
    DECLARE_QGC_COLOR(primaryButton,        "#7fcdf2", "#0284c7", "#7fcdf2", "#0284c7")
    DECLARE_QGC_COLOR(primaryButtonText,    "#0f2c42", "#ffffff", "#0f2c42", "#ffffff")
    DECLARE_QGC_COLOR(textField,            "#ffffff", "#ffffff", "#ffffff", "#ffffff")
    DECLARE_QGC_COLOR(textFieldText,        "#8aa6b8", "#0f2c42", "#8aa6b8", "#0f2c42")
    DECLARE_QGC_COLOR(mapButton,            "#585858", "#333333", "#585858", "#000000")
    DECLARE_QGC_COLOR(mapButtonHighlight,   "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_QGC_COLOR(mapIndicator,         "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_QGC_COLOR(mapIndicatorChild,    "#585858", "#766043", "#585858", "#766043")
    DECLARE_QGC_COLOR(colorGreen,           "#008f2d", "#008f2d", "#00e04b", "#00e04b")
    DECLARE_QGC_COLOR(colorYellow,          "#a2a200", "#a2a200", "#ffff00", "#ffff00")
    DECLARE_QGC_COLOR(colorYellowGreen,     "#799f26", "#799f26", "#9dbe2f", "#9dbe2f")
    DECLARE_QGC_COLOR(colorOrange,          "#bf7539", "#bf7539", "#de8500", "#de8500")
    DECLARE_QGC_COLOR(colorRed,             "#b52b2b", "#b52b2b", "#f32836", "#f32836")
    DECLARE_QGC_COLOR(colorGrey,            "#808080", "#808080", "#bfbfbf", "#bfbfbf")
    DECLARE_QGC_COLOR(colorBlue,            "#0ea5e9", "#0ea5e9", "#0ea5e9", "#0ea5e9")
    DECLARE_QGC_COLOR(alertBackground,      "#eecc44", "#eecc44", "#eecc44", "#eecc44")
    DECLARE_QGC_COLOR(alertBorder,          "#808080", "#808080", "#808080", "#808080")
    DECLARE_QGC_COLOR(alertText,            "#000000", "#000000", "#000000", "#000000")
    DECLARE_QGC_COLOR(missionItemEditor,    "#585858", "#dbfef8", "#585858", "#585d83")
    DECLARE_QGC_COLOR(toolStripHoverColor,  "#c9c9c9", "#bfeafc", "#c9c9c9", "#bfeafc")
    DECLARE_QGC_COLOR(statusFailedText,     "#8aa6b8", "#0f2c42", "#8aa6b8", "#0f2c42")
    DECLARE_QGC_COLOR(statusPassedText,     "#8aa6b8", "#0f2c42", "#8aa6b8", "#0f2c42")
    DECLARE_QGC_COLOR(statusPendingText,    "#8aa6b8", "#0f2c42", "#8aa6b8", "#0f2c42")
    DECLARE_QGC_COLOR(toolbarBackground,    "#00ffffff", "#00ffffff", "#00ffffff", "#00ffffff")
    DECLARE_QGC_COLOR(groupBorder,          "#9edcf5", "#0ea5e9", "#9edcf5", "#0ea5e9")
    DECLARE_QGC_COLOR(modifiedParamValue,   "#bf7539", "#bf7539", "#de8500", "#de8500")

    // Colors not affecting by theming
    //                                                      Disabled     Enabled
    DECLARE_QGC_NONTHEMED_COLOR(brandingPurple,             "#4A2C6D", "#4A2C6D")
    DECLARE_QGC_NONTHEMED_COLOR(brandingBlue,               "#48D6FF", "#6045c5")
    DECLARE_QGC_NONTHEMED_COLOR(toolStripFGColor,           "#707070", "#ffffff")
    DECLARE_QGC_NONTHEMED_COLOR(photoCaptureButtonColor,    "#707070", "#ffffff")
    DECLARE_QGC_NONTHEMED_COLOR(videoCaptureButtonColor,    "#f89a9e", "#f32836")

    // Colors not affecting by theming or enable/disable
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderLight,          "#ffffff")
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderDark,           "#000000")
    DECLARE_QGC_SINGLE_COLOR(mapMissionTrajectory,          "#be781c")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonInterior,         "green")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonTerrainCollision, "red")

}

void QGCPalette::setColorGroupEnabled(bool enabled)
{
    _colorGroupEnabled = enabled;
    emit paletteChanged();
}

void QGCPalette::setGlobalTheme(Theme newTheme)
{
    // Mobile build does not have themes
    if (_theme != newTheme) {
        _theme = newTheme;
        _signalPaletteChangeToAll();
    }
}

void QGCPalette::_signalPaletteChangeToAll()
{
    // Notify all objects of the new theme
    for (QGCPalette *palette : std::as_const(_paletteObjects)) {
        palette->_signalPaletteChanged();
    }
}

void QGCPalette::_signalPaletteChanged()
{
    emit paletteChanged();
}
