#include "AuthController.h"

#include <QtCore/QCryptographicHash>
#include <QtCore/QDebug>
#include <QtCore/QRegularExpression>
#include <QtCore/QSettings>

AuthController::AuthController(QObject *parent)
    : QObject(parent)
{
}

AuthController *AuthController::instance()
{
    static AuthController *const _instance = new AuthController();
    return _instance;
}

QString AuthController::_normalize(const QString &username)
{
    // QSettings treats '/' and '\' as group separators, so keys must be sanitized.
    QString key = username.trimmed().toLower();
    key.replace(QRegularExpression(QStringLiteral("[\\\\/]")), QStringLiteral("_"));
    return key;
}

QString AuthController::_hash(const QString &password) const
{
    const QByteArray salted = QByteArray("cda-salt-") + password.toUtf8();
    return QString::fromLatin1(
        QCryptographicHash::hash(salted, QCryptographicHash::Sha256).toHex());
}

void AuthController::_setError(const QString &msg)
{
    if (_errorString != msg) {
        _errorString = msg;
        emit errorStringChanged();
    }
}

void AuthController::clearError()
{
    _setError(QString());
}

bool AuthController::login(const QString &username, const QString &password)
{
    if (username.trimmed().isEmpty() || password.isEmpty()) {
        _setError(tr("Enter username and password"));
        return false;
    }

    QSettings settings;
    settings.beginGroup(QStringLiteral("Users"));
    const QString stored = settings.value(_normalize(username)).toString();
    settings.endGroup();

    if (stored.isEmpty() || stored != _hash(password)) {
        _setError(tr("Invalid username or password"));
        return false;
    }

    _setError(QString());
    _currentUser = username.trimmed();
    _loggedIn    = true;
    emit loggedInChanged();
    return true;
}

bool AuthController::registerUser(const QString &username,
                                  const QString &password,
                                  const QString &confirmPassword)
{
    const QString trimmed = username.trimmed();

    if (trimmed.length() < 3) {
        _setError(tr("Username must be at least 3 characters"));
        return false;
    }
    if (password.length() < 6) {
        _setError(tr("Password must be at least 6 characters"));
        return false;
    }
    if (password != confirmPassword) {
        _setError(tr("Passwords do not match"));
        return false;
    }

    const QString key = _normalize(trimmed);

    QSettings settings;
    settings.beginGroup(QStringLiteral("Users"));
    if (settings.contains(key)) {
        settings.endGroup();
        _setError(tr("That username is already taken"));
        return false;
    }
    settings.setValue(key, _hash(password));
    settings.endGroup();
    settings.sync();

    _setError(QString());
    emit registrationSucceeded(trimmed);
    return true;
}

void AuthController::logout()
{
    qDebug() << "[AUTH-DEBUG] AuthController::logout() called, instance =" << this
             << " loggedIn before =" << _loggedIn;
    _currentUser.clear();
    _loggedIn = false;
    emit loggedInChanged();
    qDebug() << "[AUTH-DEBUG] AuthController::logout() finished, loggedIn after =" << _loggedIn;
}